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
 `AWSMusingsProfile` | `default` | The AWS CLI configured profile used with all invocations of the `aws` CLI.
 `AWSMusingsS3Bucket` | `aws-musings-us-east-1` | The S3 bucket where the CloudFormation scripts and supporting files are uploaded to and loaded from.
 `AWSMusingsS3URL` | `https://s3.amazonaws.com/$AWSMusingsS3Bucket` | The URL to the `aws-musings` S3 bucket.
 `AWSMusingsS3ACL` | `public-read` | The Access Control List of files uploaded with the `upload.sh` script (see [Making Modifications](#making-modifications) below). See this [ACL overview](http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) for more details.
 `StackOrg` | None | <a name="stack-org">The</a> organization name. Used as a prefix to all CloudFormation stacks names. Multiple stacks should all use the same organization. This variable will typically identify the entity as a whole. This variable is commonly set to the Top-Level Domain name (e.g.: `example` for `example.com`).
 `StackEnv` | `dev` | <a name="stack-env">The</a> environment name. Also used as a prefix to all CloudFormation stack names. Multiple stacks can all use the same environment. Environments are commonly named `prod`, `stage` and `dev`. Names the DNS zones within the external and internal DNS zones (i.e.: with an external DNS of `example.com`, the full external zone would be `dev.example.com`.

## Chaining Outputs to Inputs

Several scripts will print out environment variables for use by subsequent scripts. Cut and paste these values into your terminal session so other scripts can use them as inputs. You may also want to store the values somewhere safe depending on the lifecycle of your AWS artifacts.

The following shows the output of the script to create a VPC and the subsequent invocation of the private infrastructure script:
```bash
$ ./infrastructure/scripts/vpc.sh create
export VPCId=vpc-0123456789abcdef0

$ export VPCId=vpc-0123456789abcdef0

$ ./infrastructure/scripts/public.sh create
...
```
**Note:** The environment variable `VPCId` was output by the `vpc.sh` script and *_manually_* copied and executed after the `vpc.sh create` completed. The `public.sh create` script then was able to use the value when it was subsequently executed.

# CIDR Addressing Scheme for Private IPv4 Addresses

`aws-musings` attempts to be unassuming about the CIDR addressing scheme for private IPv4 addresses. The only recommendation can be inferred by the default CIDR ranges but these values are completely overridable. The default CIDRs used in `aws-musings` define a `/16` VPC (10.0.0.0/16) with 256 subnets defined by the third octet. The third octet divides public subnets (`0` through `49`) from private subnets (`50` through `255`). The default of the [infrastructure](./infrastructure) sub-project also reserves the first three public subnets (`0`, `1`, and `2`).

# IPv6 CIDR Addressing Scheme

AWS will provide an IPv6 `/56` CIDR for each VPC (when using the AWS console). `aws-musings` uses several `ipv6-defaults.sh` scripts to divvy up the `/56` into 256 `/64` subnets. By default the subnets are partition in a scheme similar to the above IPv4 scheme with subnet `00` through `2f` being reserved for public subnets and `30` through `ff` used for private subnets.

# Sub-Projects
 Name | Description
------|-------------
[infrastructure](./infrastructure) | Creates the core constructs starting with the VPC. This project builds artifacts that are prerequisites for all other projects
[containers](./containers) | Builds a basic container framework using Fargate.
 | **Other**
[Gluster Proof of Concept](./gluster-poc-us-west-2) | Deploys a GlusterFS test framework

# Making Modifications

Whether you are adding new content or forking `aws-musings` into a whole new direction (pull requests are always welcome), you will need to have an S3 bucket to host the CloudFormation scripts. You can upload some of the simple scripts directly into the AWS console but most of the scripts pull down supporting scripts from S3 or have nested CloudFormation scripts (which must be pulled from S3). In most cases you won't have update permissions to the default `aws-musings-us-east-1` S3 bucket.

Simply create your own S3 bucket that you can read and write to, set the path to the bucket via the `AWSMusingsS3URL` environment variable, then run the `./scripts/upload.sh` script. All scripts executed with the same `AWSMusingsS3URL` variable will pull all scripts (CloudFormation and otherwise) from the specified S3 bucket.

**NOTE:** Take care not to put sensitive content in your `aws-musings` working directory such as passwords or private keys. All files in your working directory are uploaded to the S3 bucket
