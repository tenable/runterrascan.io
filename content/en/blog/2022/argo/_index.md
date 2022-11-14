---
date: 2021-05-19
title: "Automating Terraform Security with pre-commit-terraform and Terrascan"
linkTitle: "Automating Terraform Security"
description: ""
author: Cesar Rodriguez ([Developer Advocate](https://github.com/cesar-rodriguez))
resources:
- src: "**.{png,jpg}"
  title: "Image #:counter"
  params:
    byline: ""
---

One of the best things about using Terraform to manage your systems is that best practices can be defined and applied to your templates in a manner similar to what is done with application code. This means that linting and testing the infrastructure as code (IaC) templates for quality, operational, and security issues can be accomplished easily, using some of the same workflows as application code. The most common place to enforce coding best practices is in continuous integration (CI) pipelines. 

You can configure your CI pipelines to help enforce compliance with your coding policies by automatically executing validation scripts and tools and failing the CI job whenever there’s a violation. These can be configured to prevent any merges to your main branch if there’s a violation that could be considered a blocker to your system. 

One of the drawbacks to relying on pipelines for enforcement is that they are bottlenecks in the development process.  Every code change goes through them, and one bad commit can break the build for everybody.  This can be extremely disruptive when teams are iterating quickly. One way to avoid this problem is to use a pre-commit hook to enforce standards locally on a developer’s system before pushing code to the repository. By adding a pre-commit configuration to your repository, you can help those contributing to your repository test locally to ensure their commit will not break the build once it is pushed and CI pipelines are completed. 

For Terraform, one of the best projects out there to configure your repository’s pre-commit scripts is [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform). The pre-commit-terraform project includes multiple git hooks specifically for Terraform that can help with linting, documentation, operational, and security compliance. As part of its security toolbox pre-commit-terraform includes [Terrascan](https://runterrascan.io), the static code analyzer for IaC maintained by Accurics.

## Terraform security with pre-commit-terraform

Let’s take a look at how Terrascan can be leveraged to find Terraform security issues using pre-commit-terraform in an example. 

The first step is to install pre-commit. Alternate ways of installing are available here.
`~ ➜  pip install pre-commit`

Once pre-commit is installed we can create the repository that will contain our Terraform templates.
```
~ ➜  mkdir pre-commit-tf-example
~ ➜  git init pre-commit-tf-example
~ ➜  cd pre-commit-tf-example
```

We’ll add a .pre-commit-config.yaml file in the root of our repository configured to use the terrascan git hook within the pre-commit-terraform repository. We’ll reference release v1.50.0 which is the latest release as of this writing.

```
pre-commit-tf-example git:(main) ✗ ➜  cat .pre-commit-config.yaml
repos:
-   repo: https://github.com/antonbabenko/pre-commit-terraform
	rev: v1.50.0
	hooks:
	-   id: terrascan
pre-commit-tf-example git:(main) ✗ ➜
```


Now, we’ll run the pre-commit install, which will configure pre-commit for this particular repository using the information obtained from the .pre-commit-config.yaml file.
```
pre-commit-tf-example git:(master) ✗ ➜  pre-commit install
pre-commit installed at .git/hooks/pre-commit
pre-commit-tf-example git:(master) ✗ ➜  
```

Let’s add a Terraform template with a known violation. In this case we’re going to add an AWS S3 object resource that’s missing the encryption at rest configuration.
```
pre-commit-tf-example git:(master) ✗ ➜  cat main.tf
variable "bucket" {}

resource "aws_s3_bucket_object" "html" {
  bucket   	= var.bucket
  key      	= "index.html"
  source   	= "index.html"
  acl      	= "public-read"
  content_type  = "text/html"
  etag     	= filemd5("index.html")
}
pre-commit-tf-example git:(master) ✗ ➜  
```

Once we try to commit the Terraform template, pre-commit will execute Terrascan. Since we have not set encryption for this object, Terrascan will fail and provide feedback on what it found.
```
pre-commit-tf-example git:(master) ✗ ➜  git add . && git commit -m 'add terraform'
[INFO] Initializing environment for https://github.com/antonbabenko/pre-commit-terraform.
terrascan................................................................Failed
- hook id: terrascan
- exit code: 3

Violation Details -
    
    Description	:    Ensure S3 object is Encrypted
    File       	:    main.tf
    Line       	:    3
    Severity   	:    MEDIUM
    -----------------------------------------------------------------------
    

Scan Summary -

    File/Folder     	  :    /Users/therasec/pre-commit-tf-example
    IaC Type        	  :    terraform
    Scanned At      	  :    2021-05-10 03:32:22.117445 +0000 UTC
    Policies Validated  :    607
    Violated Policies   :    1
    Low             	  :    0
    Medium          	  :    1
    High             	  :    0
pre-commit-tf-example git:(master) ✗ ➜  
```

Let's fix the issue by configuring server side encryption for the object and try to commit again.
```
pre-commit-tf-example git:(master) ✗ ➜  cat main.tf

variable "bucket" {}

resource "aws_kms_alias" "a" {
  name = "alias/my-key-alias"
}

resource "aws_s3_bucket_object" "html" {
  bucket             	= var.bucket
  key                	= "index.html"
  source             	= "index.html"
  acl                	= "public-read"
  content_type       	= "text/html"
  etag               	= filemd5("index.html")
  server_side_encryption = "AES256"
  kms_key_id         	= data.aws_kms_alias.a.target_key_id
}
pre-commit-tf-example git:(master) ✗ ➜  
```

Since we added the server_side_encryption and kms_key_id parameters, the issue should be solved and we should be able to perform `git commit`. 
```
pre-commit-tf-example git:(master) ✗ ➜  git add .
pre-commit-tf-example git:(master) ✗ ➜  git commit -m 'add terraform'
terrascan................................................................Passed
[master (root-commit) 41138a6] adds terraform
 2 files changed, 22 insertions(+)
 create mode 100644 .pre-commit-config.yaml
 create mode 100644 main.tf
pre-commit-tf-example git:(master) ✗ ➜  
```


By using a pre-commit hook we’re able to get quick feedback into security issues affecting the code we’re trying to commit. This allows us to solve issues quickly and prevent any misconfigurations from being merged into our baseline code. Terrascan can be leveraged as a pre-commit hook and as part of your CI/CD pipelines to find Terraform security weaknesses and is included as part of the pre-commit-terraform project.
