---
categories:
- Munki
- Terraform
date: "2018-10-31T17:58:42Z"
title: Deploying a Munki repo in five minutes with Terraform
---

[terraform-munki-repo](https://github.com/grahamgilbert/terraform-munki-repo) is a [Terraform](https://terraform.io) module that will set up a production ready Munki repo for you. More specifically it will create:

* An s3 bucket to store your Munki repo
* An s3 bucket to store your logs
* A CloudFront Distribution so your clients will pull from an AWS endpoint near them
* A Lambda@Edge function that will set up basic authentication

## Why?

A Munki repo is a basic web server. But you still need to worry about setting up one or more servers, patching those servers, scaling them around the world if you have clients in more than one country.

Amazon Web Services has crazy high levels of up time - more than we could ever manage ourselves. CloudFront powers some of the world's busiest websites without breaking a sweat, so it can handle your Munki repo without any trouble.

So it makes sense to offload the running of these services so we can get on with our day.
<!--more-->

## How do I use it?!

### Initial Terraform / AWS Setup

1. [Register for an AWS account](https://aws.amazon.com/) if you haven't already got one.
2. Once logged in and youv'e set up billing, head over to IAM and create a user with the `AdministratorAccess` permission.
3. Generate an access key and secret for the user. Download the CSV.
4. Install [homebrew](https://brew.sh)
5. `brew install awscli`
6. `brew install terraform`
7. `aws configure` and follow the prompts to log in and to set a default region (I like `us-east-1` but choose one where you are happy having your data stored)

### Using the thing

Create a file called `main.tf` wherever you want to store these things. Put the following content in it - adjust the variables to match what you want the bucket to be called (the name must be globally unique across all of Amazon), and the username and password your Munki clients will use to access the repo).

``` go
module "munki" {
  source          = "git::https://github.com/grahamgilbert/terraform-munki-repo.git//munki"
  munki_s3_bucket = "my-munki-bucket"
  username        = "munki"
  password        = "ilovemunki"
  # price_class is one of PriceClass_All, PriceClass_200, PriceClass_100
  price_class = "PriceClass_100"
}
```

And now it's time to put Terraform to work. Commands you need to type are prefaced with a `$`.

``` bash
$ terraform init
Initializing modules...
- module.munki
  Getting source "git::https://github.com/grahamgilbert/terraform-munki-repo.git//munki"

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.42.0)...
- Downloading plugin for provider "template" (1.0.0)...
- Downloading plugin for provider "archive" (1.1.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.archive: version = "~> 1.1"
* provider.aws: version = "~> 1.42"
* provider.template: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

$ terraform get
- module.munki

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.template_file.basic_auth_js: Refreshing state...
data.archive_file.basic_auth_lambda_zip: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

[A load more output that I have snipped...]

Plan: 7 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

You will see a `terraform.tfstate` file appear. This is how Terraform keeps track of what it has created and what the present state is. Do not delete this file, and whilst you _can_ make changes in the AWS GUI, there is definitely the potential for your state file to get messed up, so I would suggest to editing the resources we are creating only with Terraform. And if you are thinking that a local state file sounds difficult to work with in a team, you would be right - you should definitely look at moving to a backend such as the [s3 backend](https://www.terraform.io/docs/backends/types/s3.html).

If everything goes well and Terraform says it will create everything you expect, you can apply (type in `yes` when you are asked):

``` bash
$ terraform apply

[yet more output snipped]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

Then you can get your distribution's url (you want the CloudFront one, not the s3 one):

``` bash
$ terraform state show module.munki.aws_cloudfront_distribution.www_distribution | grep domain_name
```

Head to your new Munki repo's address and all being well you should be able to log in with your chosen username and password. Note: it can take a few minutes for CloudFront distributions to work everywhere - if you can't connect, check in the AWS console that it has finished deploying before panicking.

## Getting your Munki repo into s3

Assuming your repo is in `/Users/Shared/munki_repo` - adjust this path for your environment.

``` bash
$ aws s3 sync "/Users/Shared/munki_repo" s3://my-bucket-name --exclude '*.git/*' --exclude '.DS_Store' --delete
```

Now it's just a matter of configuring your Munki clients to connect to your new repo. The [Munki wiki](https://github.com/munki/munki/wiki/Using-Basic-Authentication#configuring-the-clients-to-use-a-password) has you covered there.

## Wrap up

In just a few minutes you have deployed a Munki repo that will handle 10's of thousands of clients (or just 10 - it's just as good for small deployments), describing your infrastructure in code. This means the deployment is repeatable and reliable. If you need to change the password or username for basic auth, simply edit the variable and run `terraform plan` and `terraform apply` again. No messing with the AWS GUI, no potential for clicking on the wrong thing.