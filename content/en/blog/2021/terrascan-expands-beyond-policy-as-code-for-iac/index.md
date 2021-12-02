---
date: 2021-12-02
title: "Terrascan Expands Beyond Policy as Code for IaC"
linkTitle: "Terrascan Expands Beyond Policy as Code for IaC"
description: ""
author: Jon Jarboe ([Developer Advocate](https://www.accurics.com/blog/author/jjarboe/))
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: ""
---

Terrascan emerged from the need for a scalable way to ensure that cloud infrastructure configuration adheres to evolving security best practices. It helps identify issues such as missing or misconfigured encryption on resources and communication, and inadvertent exposure of cloud services. Terrascan fundamentally enhances the value of Infrastructure as Code (IaC) used by organizations to define and manage cloud infrastructure, and improves security by enabling teams to eliminate risk before infrastructure is deployed.

Policy as Code has proven a great fit for enforcing policies in automated workflows, and Terrascan's focus on Infrastructure as Code (IaC) such as Terraform and Kubernetes has filled an important role.  As we integrated Terrascan into DevOps tooling, pipelines and software supply chains, we realized that IaC is not the only source of risk we can help mitigate before deployment.

Over the past few months, we've been busy expanding Terrascan's ability to enforce policies across multiple important dimensions of risk.

## Addressing Risks in IaC and Container Source Files

We added support for scanning Dockerfiles, to help identify security misconfigurations in container-based architectures including Kubernetes.  We also added support for Azure Resource Manager (ARM) templates, an IaC technology that’s native to Azure, and for scanning CloudFormation templates including nested stacks.

Adding support for new input formats includes creating policies for relevant security risks in those formats.  For example, we added numerous Dockerfile policies including one to ensure that Dockerfiles don't RUN commands as root.

## Managing Vulnerability Risks in Containers

In addition to identifying security misconfigurations in IaC, Terrascan can now identify security vulnerabilities in container images referenced from Elastic Container Registry (ECR), Azure Container Registry, Google Container Registry, Google Artifact Registry, and Harbor.  This is especially useful for ensuring the absence of vulnerabilities in custom and third-party containers used and built in your development pipelines.

## Enforcing Policy During Deployment to Kubernetes Clusters

Terrascan can now be used as an admission controller for Kubernetes, enforcing policies as changes are applied to the cluster and preventing security issues from making it into the runtime environment.  Gone are the days of managing different tools and policies for pipelines and runtime.  Terrascan enables you to enforce the same policies in development and runtime!

## Improving Relevance with Prioritization and Filtering

Finding violations is important, but sometimes less is more.  Terrascan now offers the ability to prioritize or de-prioritize issues based on specific levels of severity for policies in each IaC file.  This helps tailor policies within Terrascan for the particular use case or architecture being tested, so you can focus specifically on the issues you care most about.

## Deeper Integrations, Better Automation

Automating policy enforcement into existing workflows ensures that controls are applied consistently without increasing friction in the development process.  The Terrascan GitHub action can be used within GitHub workflows to detect and prevent security issues from being merged into your code repository.

For those that need earlier enforcement, evaluating IaC even before code is committed into version control, Terrascan provides a pre-commit hook which runs on the developer workstation before code changes are committed into the git repository.

## Better Collaboration with Reporting and Compliance Processes

Enforcing policies in development processes is important, but it's sometimes just as important to be able to demonstrate that development processes are continuously compliant with the security policy.  Terrascan has added support for SARIF output to facilitate integration with common compliance and security reporting tools, such as GitHub security reports.

## Easier Custom Policy Development for Advanced Needs

Terrascan includes an extensive library of policies and best practices, but sometimes you need to implement policies that address your unique requirements or circumstances.  The newly published Terrascan Rego Editor, a VS Code extension, makes it easier to create and test policies with a seamless workflow driven in the IDE.

