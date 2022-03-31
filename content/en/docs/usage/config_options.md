---
title: "Configuration File"
linkTitle: "Configuration File"
weight: 50
description: >
      Configure Terrascan via it's configuration file.
---

You can provide a configuration file in TOML format to configure the Terrascan.

## Command to specify config File

Use the `-c` or `--config-path` flag provide a TOML configuration file for Terrascan.

``` Bash
$ terrascan scan -c <config file path>
```

 Here's an example config file:

``` TOML
[notifications]
    [notifications.webhook]
    url = "https://httpbin.org/post"
    token = "my_auth_token"

[severity]
level = "medium"
[rules]
    skip-rules = [
        "accurics.kubernetes.IAM.107"
    ]

[k8s-admission-control]
    denied-categories = [
        "Network Ports Security"
    ]
    denied-severity = "high"
    dashboard=true

[policy]
environment = "<environment_url>"
access_token = "<access_token>"

```

You can specify the following configurations:

*  **scan-rules** - Specify one or more rules to scan. All other rules in the policy pack will be skipped.
*  **skip-rules** - Specify one or more rules to skip while scanning. All other rules in the policy pack will be applied.
*  **severity** - the minimal level of severity of the policies to be scanned and displayed. Options are high, medium and low
*  **category** - the list of type of categories of the policies to be scanned and displayed
*  **notifications** - This configuration can be used, as seen in the example above, to send the output of scans as a webhook to a remote server. Note that the `--notification-webhook-url` CLI flag will override any URLs configured through a configuration file.


**k8s-admission-control** - Config options for K8s Admission Controllers and GitOps workflows:

*  **denied-severity** - Violations of this or higher severity will cause and admission rejection. Lower severity violations will be warnings. Options are high, medium. and low
*  **denied-categories** - Violations from these policy categories will lead to an admission rejection. Policy violations of other categories will lead to warnings.
*  **dashboard=true** - enable the `/logs` endpoint to log and graphically display K8s admission requests and violations. Default is `false`


**policy** - Config options for policy source and destination path information
*  **path** - Sets the local path for terrascan files including policies
*  **rego_subdir** - Sub directory within the base path for caching policies

*  **repo_url** - Repository from which all the policies must be downloaded
*  **branch** - Specific branch out of the repository to pull the policies

*  **environment** - Authenticated environment URL for downloading policies. _Supercedes_ any other source if its set along with a valid access token
*  **access_token** - Authentication token to download policies from authenticated environment

## Logging
Logging can be configured by using the `-l` or `--log-level` flags with possible values being: debug, info, warn, error, panic, or fatal. This defaults to "info".

In addition to the default "console" logs, the logs can be configured to be output in JSON by using the `-x` or `--log-type` flag with the value of `json`.
