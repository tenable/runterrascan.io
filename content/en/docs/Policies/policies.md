---
title: "Policy Overview"
linkTitle: "Policy Overview"
weight: 10
description: >
    Configuring policies, and writing custom ones.
---

Terrascan policies are written using the [Rego policy language](https://www.openpolicyagent.org/docs/latest/policy-language/). With each rego policy, a JSON "rule" file is included which defines metadata for the policy. Policies included within Terrascan are stored in the [pkg/policies/opa/rego](https://github.com/tenable/terrascan/tree/master/pkg/policies/opa/rego) directory.

## Updating Terrascan with the latest policies

The first time using Terrascan, if the `-p` flag is not specified, Terrascan will download the latest policies from the Terrascan repository. You can update your local environment to the latest policies published in the repository by running `terrascan init`.

## Ignoring Policies on a scan

Terrascan keeps a copy of policies on your local filesystem on the `~/.terrascan/pkg/policies/opa/rego` directory. You can also specify a particular directory with rego policies to scan by using the `-p` flag. Terrascan allows you to ignore policies from scans by using the [--skip-rules](../../usage/command_line_mode/#list-of-options-for-scan-command) flag or using [in-file instrumentation](../../usage/in-file_instrumentation/) to skip policies on a particular resource.

## Adding policies

For each policy, there are 2 files required by Terrascan, a rule `.json` file with metadata for the policy and a `.rego` [rego](https://www.openpolicyagent.org/docs/latest/policy-language/) file for the policy itself.

### Writing an OPA rego policy file
The input for the rego policies is the normalized input from the IaC provider. When writing policies you can obtain this as a normalized `.json` by using the `--config-only` flag of the scan command in combination with `-o json`. Let's use this Terraform HCL file for example:

``` hcl
resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"

  private = false

  template {
    owner = "github"
    repository = "terraform-module-template"
  }
}
```

Here's the output of the `--config-only` flag.

``` json
$ terrascan scan -i terraform --config-only -o json
{
  "github_repository": [
    {
      "id": "github_repository.example",
      "name": "example",
      "source": "main.tf",
      "line": 1,
      "type": "github_repository",
      "config": {
        "description": "My awesome codebase",
        "name": "example",
        "private": false,
        "template": [
          {
            "owner": "github",
            "repository": "terraform-module-template"
          }
        ]
      }
    }
  ]
}
```


You can use this `.json` output as the input in the [rego playgound](https://play.openpolicyagent.org/). The following policy can be used on the above Terraform to flag if the GitHub repository has been created with `private = false`.

```
package accurics

privateRepoEnabled[api.id] {
    api := input.github_repository[_]
    not api.config.private == true
    not api.config.visibility == "private"
}
```

A successful policy will trigger the following output:

``` json
{
    "privateRepoEnabled": [
        "github_repository.example"
    ]
}
```

### The Rule JSON file

The rule files follow this naming convention: `AC_<policy_type>_<next_available_rule_number>.json` where `<policy_type>` is the upper case of any supported policy types by terrascan. The supported policy types can be fetched from Terrascan's help menu: `terrascan scan -h | grep "policy-type"`.

>**Note**: The previous naming convention was: `<cloud-provider>.<resource-type>.<rule-category>.<severity>.<next-available-rule-number>.json`. This has been deprecated.

Here's an example of the contents of a rule file:

``` json
{
	"name": "unrestrictedIngressAccess",
	"file": "unrestrictedIngressAccess.rego",
	"policy_type": "aws",
	"resource_type": "aws_db_security_group",
	"template_args": {
		"name": "unrestrictedIngressAccess",
		"prefix": "",
		"suffix": ""
	},
	"severity": "HIGH",
	"description": "It is recommended that no security group allows unrestricted ingress access",
	"category": "NETWORK_SECURITY",
	"version": 1,
	"id": "AC_AWS_0001"
}
```

| Key                  | Value                                         |
| -------------------- | --------------------------------------------- |
| name                 | Short name for the rule                       |
| file                 | Filename of the Rego policy                  |
| policy_type          | Type of cloud provider used by this rule (e.g. aws, azure, docker, gcp, github, k8s, etc.) |
| resource_type        | IaC resource applicable to the policy         |
| template_args        | Used for making rego policies unique          |
| severity             | Likelihood * impact of issue                  |
| description          | Description of the issue found with this rule |
| ruleReferenceId (*deprecated*) | This field was used in previous versions of Terrascan, but has been replaced by *id*. |
| category            | Descriptive category for this rule             |
| version             | Version number for the rule/rego               |
