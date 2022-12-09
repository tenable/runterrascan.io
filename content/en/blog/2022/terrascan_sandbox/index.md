---
date: 2022-12-09
title: "Test your cloud-native IaC in your browser with the Terrascan Sandbox"
linkTitle: "Try Terrascan Sandbox"
description: ""
author: John S. Tonello ([Technical Marketing Manager](https://github.com/jtonello))
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: ""
---


Terrascan is open-source software from Tenable that scans infrastructure-as-code (IaC) for security misconfigurations and violations before the code is provisioned into cloud-native infrastructure. Now, you can try Terrascan right from your browser with the new [Terraform Sandbox](https://tenable.com/terrascan).

The Terraform Scanbox can test a variety of code, including:
- Azure Resource Manager (ARM)
- CloudFormation Templates (CFT)
- Docker
- Kubernetes
- Terraform
- Terraform plans

Simply paste your code into the code window, select the appropriate IaC version you’re using, and click Scan. You’ll immediately see security violations, details about their severity and the [Tenable Research policies](https://tenable.com/policies) that are impacted.

![Try Terrascan](terrascan_sandbox.gif)

Code is analyzed and compared against hundreds of security policies, providing details about the origin and impact of each violation, the same capabilities you get when you download and run Terrascan on your workstation. The policy library provides details on how to remediate each problem.

Terrascan is at the heart of [Tenable Cloud Security](https://www.tenable.com/products/tenable-cs), an enterprise solution for scanning cloud-native runtimes, cloud environments and IaC. Terrascan and Tenable.cs are both part of Tenable’s mission to help organizations implement comprehensive cyber exposure management and enable sound security practices earlier in the software lifecycle.

Learn more about Terrascan, download the app or join the community by visiting [runterrascan.io](https://runterrascan.io).
