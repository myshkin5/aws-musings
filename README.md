aws-musings
===========

As part of the [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code) initiative, `aws-musings` automates as much of your AWS environment setup as possible.

The core technology used in `aws-musings` is [AWS CloudFormation](https://aws.amazon.com/cloudformation/). The CloudFormation scripts can be executed directly from the AWS console, but as each script builds on the ones before it, it's best to use the included shell scripts to facilitate the passing of inputs and outputs to each script.

# Running the Shell Scripts

## Setup

Prior to executing the shell scripts, [install](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configure](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) the AWS CLI. Also clone the repo to your workstation:
```bash
git clone https://github.com/myshkin5/aws-musings.git
```

**Note:** Although both the shell scripts and the CloudFormation scripts are cloned locally, only the shell scripts are needed. The CloudFormation scripts are actually pulled from a public S3 bucket. If you would like to fork and modify the scripts, see [Making Modifications](#making-modifications) below.

At first the sheer number of parameters might appear daunting, but most parameters either are not required, have reasonable defaults or are supplied by a previously run stack. If a parameter does not meet any of these attributes, its description will contain the text **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**. For these parameters, you may want to take steps to assure that they are defined properly such as adding them to your `~/.bashrc`.

## Environment Variables

All shell scripts support and use the following environment variables:

 Name | Default | Description
---|---|---
 `AWS_MUSINGS_S3_BUCKET` | `aws-musings-us-east-1` | The S3 bucket where the CloudFormation scripts and supporting files are uploaded to and loaded from.
 `AWS_MUSINGS_S3_URL` | `https://s3.amazonaws.com/$AWS_MUSINGS_S3_BUCKET` | The URL to the `aws-musings` S3 bucket.
 `PROFILE` | `default` | The AWS CLI configured profile used with all invocations of the `aws` CLI.
 `STACK_PREFIX` | `vkzone-dev` | Used as a prefix to all CloudFormation stacks. Multiple groups of stacks should all use the same prefix.
 `ACL` | `public-read` | The Access Control List of files uploaded with the `upload.sh` script (see [Making Modifications](#making-modifications) below). See this [ACL overview](http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) for more details.

## Chaining Outputs to Inputs

Several scripts will print out environment variables for use by subsequent scripts. Cut and paste these values into your terminal session so other scripts can use them as inputs. You may also want to store the values somewhere safe depending on the lifecycle of your AWS artifacts.

The following shows the output of the script to create a VPC and the subsequent invocation of the private infrastructure script:
```bash
$ ./infrastructure/scripts/create-vpc.sh
export VPC_ID=vpc-12345678

$ export VPC_ID=vpc-12345678

$ ./infrastructure/scripts/create-public-infrastructure.sh
...
```
**Note:** The environment variable `VPC_ID` was output by the `create-vpc.sh` script and *_manually_* copied and executed after the `create-vpc.sh` completed. The `create-public-infrastructure.sh` script then was able to use the value when it was subsequently executed.

# CIDR Addressing Scheme for Private IP Addresses

Of the four octets of any IPv4 address, `aws-musings` hardcodes the first to `10` for private IP addresses. The second octet is configurable in the infrastructure sub-project (see [SECOND_OCTET](./infrastructure#second-octet)). The third octet divides public subnets (`0` through `49`) from private subnets (`50` through `255`). The infrastructure sub-project also reserves the first three public and private subnets (`0`, `1`, `2`, `50`, `51` and `52`). Other sub-projects typically allow the third octet to be configurable.

# Sub-Projects
 Name | Description
------|-------------
[infrastructure](./infrastructure) | Lays down the basic framework starting with the VPC
 | **Other**
[Gluster Proof of Concept](./gluster-poc-us-west-2) | Deploys a GlusterFS test framework

# Making Modifications

Whether you are adding new content or forking `aws-musings` into a whole new direction (pull requests are always welcome), you will need to have an S3 bucket to host the CloudFormation scripts. You can upload some of the simple scripts directly into the AWS console but most of the scripts pull down supporting scripts from S3 or have nested CloudFormation scripts (which must be pulled from S3). In most cases you won't have update permissions to the default `aws-musings-us-east-1` S3 bucket.

Simply create your own S3 bucket that you can read and write to, set the path to the bucket via the `AWS_MUSINGS_S3_URL` environment variable, then run the `./scripts/upload.sh` script. Any `create-*` script executed with the same `AWS_MUSINGS_S3_URL` variable will pull all scripts (CloudFormation and otherwise) from the specified S3 bucket.

**NOTE:** Take care not to put sensitive content in your `aws-musings` working directory such as passwords or private keys. All files in your working directory are uploaded to the S3 bucket
