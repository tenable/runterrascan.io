---
date: 2018-10-06
title: "Easy documentation with Docsy"
linkTitle: "Announcing Docsy"
description: "The Docsy Hugo theme lets project maintainers and contributors focus on content, not on reinventing a website infrastructure from scratch"
author: Riona MacNamara ([@rionam](https://twitter.com/bepsays))
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: "Photo: Riona MacNamara / CC-BY-CA"
---

**This is a typical blog post that includes images.**

The front matter specifies the date of the blog post, its title, a short description that will be displayed on the blog landing page, and its author.

## Including images

Here's an image (`featured-sunset-get.png`) that includes a byline and a caption.

{{< imgproc sunset Fill "600x300" >}}
Fetch and scale an image in the upcoming Hugo 0.43.
{{< /imgproc >}}

The front matter of this post specifies properties to be assigned to all image resources:

```
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: "Photo: Riona MacNamara / CC-BY-CA"
```

To include the image in a page, specify its details like this:

```
{{< imgproc sunset Fill "600x300" >}}
Fetch and scale an image in the upcoming Hugo 0.43.
{{< /imgproc >}}
```

The image will be rendered at the size and byline specified in the front matter.

# Securing Infrastructure as Code Using Terrascan

I remember one of my first public cloud projects. We created a cross functional team that included representatives from the business, developers, architects, security, and operations. The goal was to have a minimum viable product for an important customer facing system as our first cloud native deployment in 12 weeks. 

At first the task seemed daunting. There was a lot to learn and implement in a short period of time, and as the representative of the security team, I wanted to make sure security was embedded into every decision we made. 

That meant having a scalable way to review and provision network security settings and configuration, identity and access management policies, and ensuring that any cloud resource was configured following security best practices.  

## IaC Benefits

Around that time I discovered a tool called Terraform and the concept of Infrastructure as Code (IaC). Using Terraform we were able to quickly provision our infrastructure in a consistent manner where the code to provision our infrastructure lived side by side to our application code.

At the same time, using Terraform to provision and manage the security of our cloud environment meant that development teams had greater visibility into how the security of the infrastructure was configured, how it affected our application, and they were empowered to submit pull requests if there were any changes needed. 

This was a huge benefit compared to the way things were done in our on-premises data center. Where we used ticketing systems to engage the security team and from the perspective of developers security was a black box that a siloed team handled. 

## The Challenge

Although IaC empowered our development teams to take ownership of their infrastructure and devops lifecycle, it also presented some challenges. Our architecture was increasingly complex due to being in a hybrid environment and the pace of change was increasing as we increased our cloud adoption.

Security defects in our IaC could be augmented and replicated through the environment if we didn’t have a way to review or control changes to prevent security defects. Issues like exposing your private network to the public internet, not encrypting any sensitive data at rest, or missing access logs could put the environment and business at risk. 

## What’s Terrascan? 

As I thought about these issues I realized that the same techniques we were using for our application’s code like static code analysis could be used to identify security weaknesses in our IaC. This would ensure security best practices were embedded as early as possible into the development lifecycle.

To solve this I developed [Terrascan](https://github.com/accurics/terrascan). Terrascan is an open source static code analyzer for Terraform. It helps you test your Terraform code to find security weaknesses including: 

*   Server side encryption misconfigurations
*   Using AWS Key Management Service (KMS) with Customer Managed Keys (CMS)
*   Encryption in-transit SSL/TLS is not enabled and configured properly
*   Security Groups open to the public internet
*   Inadvertent public exposure of cloud services
*   Access logs not enabled on resources that support them

## Using Terrascan

To install [Terrascan](https://github.com/accurics), you’ll need Python 3.6 or later installed in your system. 

<p id="gdcalert1" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image1.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert2">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>

![alt_text](images/image1.png "image_tooltip")

```
$ pip install terrascan
Collecting terrascan
  Downloading terrascan-0.2.1-py2.py3-none-any.whl (28 kB)
Requirement already satisfied: pyhcl>=0.4.4 in ./.pyenv/versions/3.7.5/envs/terrascan/lib/python3.7/site-packages (from terrascan) (0.4.4)
Installing collected packages: terrascan
Successfully installed terrascan-0.2.1
```

Now that you have Terrascan installed, lets scan some code. Here’s an example s3_bucket resource that’s missing encryption.

<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image2.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>

![alt_text](images/image2.png "image_tooltip")

```
resource "aws_s3_bucket" "my_insecure_s3_bucket" {
  bucket = "my-insecure-s3-bucket"

  logging {
	target_bucket = "logging_bucket"
	target_prefix = "log/"
  }

  tags = {
	Name    	= "my-insecure-s3-bucket"
	Environment = "production"
  }
}
```

Here are the results of running Terrascan against that resource.

<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image3.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image3.png "image_tooltip")

```
$ terrascan -l .
Logging level set to error.
........................................................................
----------------------------------------------------------------------
Ran 72 tests in 0.005s

OK

Processed 1 files in /Users/therasec/test/.

Processed on 06/20/2020 at 22:45
Results (took 0.26 seconds):

Failures: (1)
[high] [aws_s3_bucket.my_s3_bucket] should have property: 'server_side_encryption_configuration' in module ., file /Users/therasec/test/./s3.tf

Errors: (0)
```

As you can see, Terrascan detected that the s3 bucket resource is missing the “server_side_encrytpion_configuration”. 

Terrascan can be installed as a pre-commit hook to help detect issues before code is pushed into your repository. It can also be integrated into your CI/CD pipeline. You can learn more about Terrascan or contribute at [github.com/accurics/terrascan](https://github.com/accurics/terrascan).


## Accurics Commitment to Open Source

I am thrilled to join the Accurics team and continue to support [Terrascan](https://github.com/accurics) together. We’re also committed to increasing our contributions to the open source community - you can expect to see more projects from us in the future