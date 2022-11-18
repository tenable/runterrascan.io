---
date: 2022-11-14
title: "Improving Kubernetes Security"
linkTitle: "Improving Kubernetes Security"
description: ""
author: Cesar Rodriguez ([Developer Advocate](https://github.com/cesar-rodriguez))
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: ""
---

Given the mind-boggling rate of innovation and adoption of cloud native technologies, the [Terrascan](https://www.accurics.com/products/terrascan/) team at Tenable has resolved to help cloud native development teams identify and mitigate more vulnerabilities than ever.  Terrascan provides a great platform for this, since it is easy to integrate [policy as code] (https://www.tenable.com/products/tenable-cs) into development pipelines and the extensible architecture makes it easy to build flexible policies with the popular [Open Policy Agent](https://www.openpolicyagent.org/) (OPA).

With all the attention on Kubernetes security at the moment, we decided to start there.  We are focusing on a couple of common themes that underpin Kubernetes vulnerabilities.  Specifically:
* Establishing a sandbox for your containers.  It is important to establish constraints on the capabilities of your containers, so attackers cannot compromise your nodes or host systems.
* Resource management.  Configurations should specify limits for the resources that can be used by containers and pods, to prevent denial of service when demand spikes.

For simplicity, I generally refer to “pods” in the explanations below.  Many of these policies are relevant for numerous types of resources, such as pods, ReplicaSets, Deployments, etc.  Our policies actually protect all the relevant object types, even though I may only mention pods.  To fully understand which resources are protected by a particular policy, you can reference the source code or the documentation.

### Policy as Code Enforcing Resource Management

Proactive resource management is a best practice for Kubernetes.  If you do not establish limits on the resources that your containers and pods can use, then you can end up in a situation where they require more resources than are available.  These limits also help the folks managing your production environment understand the scaling characteristics of your system, since they are probably not as familiar with it as you are.

Note that these policies are relevant from a security perspective as well as an operational perspective.

To avoid these types of problems, teams should establish a policy that Kubernetes configurations must specify resource limits.  They can leverage policy as code tools like Terrascan to scan configurations and flag any that do not comply with the codified policy.

The first two policies pertain to CPU limits and requests.  In short, your pods should specify how much CPU they want, and also define a limit for how much CPU they may consume in the worst case.  This enables the scheduler to place the workload on an appropriate node with an eye to the worst case CPU consumption to avoid starving other tenants.
1. CPU Limits Should be Set
1. CPU Request Should be Set
The following configuration includes the desired settings and is compliant with our policy.  A non-compliant configuration would lack one or both of the CPU limits and requests.
```
apiVersion: v1
kind: Pod
metadata:
  name: cpu-request-limit-example
spec:
  containers:
  - name: cpu-request-limit-container
    image: images.example/app-image
    resources:
      # Applies to policy #1 (CPU limit should be set)
      limits:
        cpu: "1500m"
      # Applies to policy #2 (CPU request should be set)
      requests:
        cpu: "500m"
```
The third and fourth resource policies are similar to those above, except they apply to memory rather than CPU.  The rationale is the same.
* Memory Limits Should be Set
* Memory Requests Should be Set
```
apiVersion: v1
kind: Pod
metadata:
  name: memory-request-limit-example
spec:
  containers:
  - name: memory-request-limit-container
    image: images.example/app-image
    resources:
     # Applies to policy #3 (Memory limit should be set)
     limits:
       memory: "512M"
     # Applies to policy #4 (Memory requests should be set)
     requests:
       memory: "256M"
```
* Avoid use of vulnerable volume types
CVE-2020-8555 affects certain versions of Kubernetes, and allows an information leak when pods use certain types of volumes. This policy helps you avoid vulnerable configurations by identifying unsafe use of these volume types.

### Policy as Code Enforcing Container Sandboxes
Linux, and by extension the container runtime, provides a variety of “capabilities” that processes can use, which establish finer-grained permissions than simply testing whether they are running as root.  Perhaps more important than the need to limit the resources that containers can use, is the need to limit the capabilities that containers will have at runtime–these capabilities will increase the container’s access to the host system and the container runtime daemon.  By limiting these capabilities, you can prevent the container workload from breaking out of the container to access other processes and resources on the host system.

In the case of Kubernetes applications, breaking out the container may enable a workload to access the node upon which the workload runs, and in turn to access Kubernetes secrets which may allow access to other nodes and the control plane.
Several of these policies pertain to the [PodSecurityPolicy] (https://kubernetes.io/docs/concepts/policy/pod-security-policy/) for a particular pod or node:
* Container Should Not Be Privileged
Privileged containers can bypass restrictions in the Docker daemon, allowing them to access the host system like a privileged local process.  This is necessary for certain use cases, but should not normally be enabled for production workloads. This corresponds to the `privileged` field.
* Containers Should Not Run with AllowPrivilegeEscalation
This policy protects against applications that try to escalate their privilege entitlements at runtime, potentially gaining privileges that the container creator did not intend for them to have.
This corresponds to the `allowPrivilegeEscalation` field.

Containers generally run inside an isolated environment that prevents pods from accessing host-level information on the node such as process ids (PIDs), interprocess communication (IPC) mechanisms, the underlying host network, and so forth.  Moreover, processes running inside containers may be able to indirectly access resources on the host based on the user id (UID) under which they run.  For example, filesystem permissions are often based on UIDs.  As a result, it is important for developers to make efforts to enforce isolation within the container runtime so that workloads can’t access things which they should not be able to access.  The following rules enforce those constraints: 
1. Containers Should Not Share Host IPC Namespace
If a container is able to access the host’s IPC namespace, then it can discover and communicate with processes in other containers or on the host itself.
This corresponds to the `hostIPC` field

2. Containers Should Not Share Host Process ID Namespace
If a container is able to access the host’s PID namespace, then it can discover and potentially escalate privileges for any process on the host including itself.
This corresponds to the `hostPID` field
3. Containers Should Not Share the Host Network Namespace
If a container is able to directly access the host network, then it can operate outside the virtual network established by Kubernetes–potentially accessing the control plane or internal services which should not be accessible.
This corresponds to the `hostNetwork` field
4. Containers Should Run as a High UID to Avoid Host Conflict
Containers ideally will run under a unique UID which is not present on the host system.  This ensures that the container will not be able to access resources on the host to which it is not entitled.  If a container runs under UID 0, for example (a common default), then it might be able to access privileged files like `/etc/passwd` if it gained access to the host’s filesystem.  If the container runs under a unique UID, then it would not be able to access host-based files even if it gained access to the filesystem.
This corresponds to the `runAsUser` field
5. Ensure that readOnlyRootFileSystem is set to true
Containers with writable root filesystems may be able to modify the cached image used by other pods based on the same image.  Thus, it is important to ensure that the `readOnlyRootFilesystem` field is true.
6. Restrict Mounting Docker Socket in a Container
If a container can access the Docker daemon socket, then they can control the container runtime.  This includes listing and controlling containers, changing capabilities, and even gaining control over the host.  This rule ensures that containers are configured to prevent access to the Docker socket from within the container.

The isolation of each container is typically augmented by imposing restrictions on capabilities, security profiles, and access to kernel settings (sysctls).  The following Terrascan rules ensure that sensible restrictions are configured for containers, and that containers do not attempt to remove such restrictions:
1. Do Not Use `CAP_SYS_ADMIN` Linux Capability
The `CAP_SYS_ADMIN` capability essentially grants root privileges to the container and should be avoided for the same reasons as #6 and #7 above.
This corresponds to enabling `SYS_ADMIN` in the `allowedCapabilities` field.
1. Ensure that every pod has AppArmor profile set to runtime/default in annotations
If you use AppArmor, then you should leverage the default, secure profiles for your workloads.  This rule ensures that you are using one of the secure defaults, rather than a profile which provides insufficient protection.
This corresponds to AppArmor annotations added to the PodSecurityPolicy, as described in the [documentation] (https://kubernetes.io/docs/tutorials/clusters/apparmor/#podsecuritypolicy-annotations).
1. Ensure that seccomp profile is set to runtime/default or docker/default
An alternative to AppArmor is seccomp.  Similar to #16, users should use the secure default profiles rather than potentially insecure ones.
This corresponds to the `seccompProfile` field or seccomp annotations added to the pod, depending on the version of Kubernetes in use.
1. Ensure that forbidden sysctls are not included in pod spec
Some sysctl access is necessary for containers to operate, but sysctls are a very low-level and potentially invasive capability.  This rule ensures that containers do not enable sysctls that will represent a risk to the broader host system.
This corresponds to the `forbiddenSysctls` and `allowedUnsafeSysctls` fields.
1. Minimize Admission of Containers with Capabilities Assigned
Explicitly adding capabilities to the `allowedCapabilities` field is inherently dangerous because it gives the container capabilities beyond the secure defaults.  If an attacker were able to gain control of the container, they could leverage these extra capabilities to potentially take over the node or access the control plane.
1. Minimize Admission of Root Containers
SecurityContext should specify `runAsNonRoot` to ensure containers do not run with the root UID of 0.  See #6-#12 above for more information about the dangers of containers as root.

These new policies will enable development teams to better enforce reasonable security policies at build time, and shine a light on configurations that introduce unnecessary risk of vulnerability in the system.  By leveraging policy as code in automated pipelines, teams can effectively identify and remediate risk during development and before insecure systems are deployed.
.
Note: this series focuses on policies available on the main branch of Terrascan which may precede a release that includes the new policies.  If you want to ensure you are using the latest policies, you can delete your local policy configuration (typically in $HOME/.terrascan) and re-run terrascan init.  The policies discussed in this document were committed to the repository on 2021-01-13 and will be included in the release after 1.2.

