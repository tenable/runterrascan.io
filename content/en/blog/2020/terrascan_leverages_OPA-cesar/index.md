---
date: 2020-06-24
title: "Terrascan Leverages OPA to Make Policy as Code Extensible"
linkTitle: "Terrascan Leverages OPA"
description: ""
author: Cesar Rodriguez ([Developer Advocate](https://github.com/cesar-rodriguez))
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: ""
---

I’m really excited about our release of [Terrascan](https://github.com/accurics/terrascan) v1.0!

## Brief history of Terrascan and Accurics

When I created [Terrascan](https://github.com/accurics/terrascan), I was working on a big cloud migration project, doing assessments on my employer’s cloud security posture.  One of the most tedious parts of the job was manually reviewing Terraform to ensure it adhered to security best practices. My second child was born, and I was having sleepless nights during my paternity leave.  

I kept thinking about the problem we had where developers relied on security experts to help them secure their Infrastructure as Code (IaC). I thought that there should be a way to automatically scan IaC similar to what we were doing for application code (e.g. Java, Python, C#, etc.), where we had static code analysis tools to give developers immediate feedback on security risks.  

At the time, I couldn't find any existing [tools that could scan Terraform](https://www.accurics.com/integrations/terraform/) and meet the requirements I had.  So I put something together with some Python packages that worked with Terraform HCL, some regexes, and that's how [Terrascan was born]({{< ref "/blog/2020/securing-infrastructure-as-code-using-terrascan" >}}).  The project was really useful and I decided that the best way to maintain a project like this would be to open source it. 

A couple of months ago, I joined Accurics to start the next phase in Terrascan’s journey. We have a lot of exciting ideas for Terrascan, and perhaps a few surprises in store.  The release of v1.0 is the first step on that path.

## New features, Extensibility

Terrascan was initially designed to serve a specific need: static analysis of Terraform templates for the security risks my applications faced. A primary goal of Terrascan v1.0 is extensibility.  We’ve introduced a pluggable architecture that can use the same approach to scan Terraform, AWS CloudFormation, Kubernetes and any other type of IaC tooling.  We will be adding new configuration languages in the future, and it’s easy to extend to your needs.

In addition to allowing multiple input formats, we wanted to have a standardized way to create and apply policies across these IaC tools. So we replaced the regular expression based rules with the [Open Policy Agent](https://www.openpolicyagent.org/) (OPA) engine from the [CNCF](https://www.cncf.io/).  Using the Rego policy language it’s easy to create, modify, or extend the policies that apply to your specific needs.

The new architecture uses a common intermediate language for IaC with the idea being to be able to leverage the 500+ policies we’re initially releasing with v1.0 across AWS, GCP, and Azure in a provider agnostic way. This means, for example, that the policy we wrote to detect public S3 buckets can be leveraged when scanning Terraform, CloudFormation, or any other IaC language that provisions AWS resources. 

With v1.0 we’re also introducing server mode. This allows you to run Terrascan as a server, where an API will give you the ability to scan any IaC being sent with the policies configured. With this capability, Terrascan can be used as the central hub of policy enforcement across your organization. 

Given this new extensibility, we wanted to ensure that users have a place to share ideas and experience.  So the release of Terrascan v1.0 is accompanied by the launch of the [Accurics Community](https://discord.gg/accurics-community), a place for users of Terrascan and other Accurics solutions to discuss and collaborate.  Please check it out, and remember that it’s only as useful as what you put into it.

## Dedicated to open source, vision for future

Security is an important, foundational concern of any cloud project, and open source tools like Terrascan help to standardize and democratize security in a way that anyone can contribute to.  It benefits all organizations, and the community itself, to have security policies exposed for everyone to look at so we can quickly identify the best practices, and then apply those consistently across all applications.

Be safe.

{{< youtube sJ_sw6dI16I >}}
