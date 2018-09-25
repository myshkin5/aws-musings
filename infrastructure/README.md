infrastructure
==============

Creates the core constructs starting with the VPC. This project builds artifacts that are prerequisites for all other projects.

# Prerequisites

1. **Jump Box SSH Key Pair:** Via the EC2 console, create or import an SSH key pair named `jump-box`. If an alternate name is used, specify the name via the [`JumpBoxKeyName`](#jump-box-key-name) parameter. This SSH key is only used to connect to the `jump-box` instance from the open Internet so distribute it carefully.

    **Note:** For convenience the following `$HOME/.ssh/config` file can be used to manage the jump box SSH key (assumes the `jump-box` private key is stored in `$HOME/.ssh/id_rsa_jump_box` with [`StackEnv`](#stack-env) and [`FullyQualifiedExternalParentDNSZone`](#fully-qualified-external-parent-dns-zone) set to `prod` and `example.com` respectively):
    ```
    Host jb jump-box jump-box.prod.example.com
      HostName jump-box.prod.example.com
      User ubuntu
      IdentityFile ~/.ssh/id_rsa_jump_box
      ForwardAgent yes
    ```

2. **Internal SSH Key Pair:** Via the EC2 console, create or import an SSH key pair named `internal`. If an alternate name is used, specify the name via the [`InternalKeyName`](#internal-key-name) parameter. This SSH key is used to connect to all infrastructure instances except the `jump-box` instance.

    **Note:** Prior to `ssh`ing to the jump box, the internal key must be added to the SSH key forwarding agent using the following command (assumes the `internal` private key is stored in `$HOME/.ssh/id_rsa_internal`):
    ```bash
    ssh-add $HOME/.ssh/id_rsa_internal
    ```

3. **Public DNS Hosted Zone:** Create a publicly accessible DNS hosted zone via the Route 53 console. The infrastructure project only uses this zone to create a DNS `A` record pointing to the `jump-box` instance (i.e.: `jump-box.prod.example.com` if [`StackEnv`](#stack-env) is set to `prod` and [`FullyQualifiedExternalParentDNSZone`](#fully-qualified-external-parent-dns-zone) is set to `example.com`).
    Note: A publicly accessible DNS zone is optional but `FullyQualifiedExternalParentDNSZone` must still be defined.

4. **Virtual Private Network (optional):** Deploy either an [AWS-compatible hardware or software VPN](https://aws.amazon.com/vpc/faqs/#C9). By doing so, the site of the VPN will have direct connectivity to your VPC without having to use the jump box.

# Stacks

## VPC

Just creates a VPC.

Note that, as of this edition, CloudFormation can't create a VPC with IPv6 enabled and therefore this stack can't be used with the subsequent stacks if IPv6 support is required. If IPv6 is required, do not use this stack and instead manually create a VPC with IPv6 support (via the console or CLI *with* DNS hostnames and DNS resolution *both* enabled) then pass the `VPCId` and IPv6 parameters to the lower stacks. Also note default IPv6 parameters are supplied by the [`ipv6-defaults.sh`](#ipv6-defaults) script.

| | |
---|---
 Definition | [`vpc.yml`](./vpc.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpc.yml
 Script | [`scripts/vpc.sh`](scripts/vpc.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Required/Default | Description
---|---|---
 `CIDRBlock` | No / `10.0.0.0/16` | The CIDR of the entire VPC.

### Outputs

 Name | Description
---|---
 `VPCId` | The id of the freshly created VPC.

## VPN

Creates network artifacts to route traffic through a VPN.

| | |
---|---
 Definition | [`vpn.yml`](./vpn.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpn.yml
 Script | [`scripts/vpn.sh`](scripts/vpn.sh)

### Parameters

 Name | Required/Default | Description
---|---|---
 `BGPASNumber` | No / `65000` | The Border Gateway Protocol Autonomous System Number.
 `CustomerGatewayIPAddress` | Yes | The public IP address of the customer gateway. **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `InternalAccessCIDRBlock` | No / `10.0.0.0/8` | The CIDR block that can access internal interfaces of public resources.
 `VPCId` | Yes | See the [VPC stack](#vpc) above.

### Outputs

 Name | Description
---|---
 `VPNGatewayId` | The VPN gateway to which route tables will be connected via route propagation.

## External DNS

Creates an external DNS hosted zone. Note this is a separate stack as the public zone it creates can be shared among several full infrastructure stacks.

NOTE: If you are using a hosted zone created by the Route 53 Registrar **_in the same AWS account it was created_**, do not use this stack. Instead define the outputs as though this stack was run (set `ExternalHostedZoneId` to the zone id provided by Route 53 and set `FullyQualifiedExternalDNSZone` to `<StackEnv>.<FullyQualifiedExternalParentDNSZone>`; `ExternalHostedZoneNameServers` does not need to be set).

NOTE: If you are using a hosted zone created by the Route 53 Registrar **_in a different AWS account than it was created_**, **_do_** use this stack. After this stack is created, you also need to add an NS record to the hosted zone created by the Route 53 Registrar (in the other AWS account) that points to the DNS servers in this zone's NS record which are output by `ExternalHostedZoneNameServers`.

| | |
---|---
 Definition | [`external-dns.yml`](./external-dns.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/external-dns.yml
 Script | [`scripts/external-dns.sh`](scripts/external-dns.sh)

### Parameters

 Name | Required/Default | Description
---|---|---
 `FullyQualifiedExternalParentDNSZone` | Yes | <a name="fully-qualified-external-parent-dns-zone">The</a> public DNS zone configured in Route 53 (should not start or end with .). **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `StackEnv` | Yes | See [`StackEnv`](../README.md#stack-env).
 `VPCId` | Yes | See the [VPC stack](#vpc) above.

### Outputs

 Name | Description
---|---
 `ExternalHostedZoneId` | The id of the external DNS hosted zone.
 `ExternalHostedZoneNameServers` | The name servers hosting this zone.
 `FullyQualifiedExternalDNSZone` | The fully qualified external DNS zone (not the parent zone passed in as a parameter) in the form of `<StackEnv>.<FullyQualifiedExternalParentDNSZone>`.

## Internal DNS

Creates an internal DNS hosted zone. Note this is a separate stack as the private zone it creates can be shared among several full infrastructure stacks.

| | |
---|---
 Definition | [`internal-dns.yml`](./internal-dns.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/internal-dns.yml
 Script | [`scripts/internal-dns.sh`](scripts/internal-dns.sh)

### Parameters

 Name | Required/Default | Description
---|---|---
 `FullyQualifiedExternalDNSZone` | Yes | See the Outputs section of the [External DNS stack](#external-dns) above.
 `InternalDNSZone` | No / `internal` | The DNS zone prepended on a public DNS zone to hold internal DNS records.
 `VPCId` | Yes | See the [VPC stack](#vpc) above.

### Outputs

 Name | Description
---|---
 `FullyQualifiedInternalDNSZone` | The fully qualified internal DNS zone.
 `InternalHostedZoneId` | The id of the internal DNS hosted zone.

## Public Infrastructure

Creates network routing artifacts for public subnets along with jump box and NAT instances.

| | |
---|---
 Definition | [`public.yml`](public.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/public.yml
 Script | [`scripts/public.sh`](scripts/public.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Required/Default | Description
---|---|---
 `AWSMusingsS3URL` | No / (see [README](../README.md#environment-variables)) | The URL of the uploaded `aws-musings` artifacts on S3.
 `ExternalHostedZoneId` | No | <a name="external-hosted-zone-id">The</a> external DNS zone to which external DNS records will be added. Optional, external records will be created if specified.
 `FullyQualifiedExternalDNSZone` | Yes | See the Outputs section of the [External DNS stack](#external-dns) above.
 `FullyQualifiedInternalDNSZone` | Yes | See the Outputs section of the [Internal DNS stack](#internal-dns) above.
 `InternalAccessCIDRBlock` | No / `10.0.0.0/8` | The CIDR block that can access internal interfaces of public resources.
 `InternalAccessIPv6CIDRBlock` | No | The IPv6 CIDR block that can access internal interfaces of public resources. Optional, if not specified, no internal IPv6 access will be configured. [*](#asterisk)
 `InternalHostedZoneId` | Yes | See the [Internal DNS stack](#internal-dns) above.
 `InternalKeyName` | No / `internal` | <a name="internal-key-name">The</a> SSH key pair used to connect to internal EC2 instances.
 `JumpBoxEIPAddress` | No | The Elastic IP address that will be assigned to the jump box instance. If not specified, a new EIP address will be allocated. By pre-allocating an EIP and specifying it via this parameter, the jump box will be accessible with the same address even though the infrastructure may have been rebuilt repeatedly.
 `JumpBoxKeyName` | No / `jump-box` | <a name="jump-box-key-name">The</a> SSH key pair used to connect to the jump box EC2 instances.
 `JumpBoxSSHCIDRIP` | No / `<current public ip>/32` | Any IP address included in this CIDR will be able to access the jump box via SSH (client must also use the `JumpBoxKeyName` SSH key pair). It is highly recommended to restrict this CIDR to only IP addresses that need to access the jump box. **DEFAULT VALUE MAY BE A SECURITY CONCERN**
 `JumpBoxInstanceType` | No / `t3.nano` | The EC2 instance type of the jump box.
 `PublicSubnetACIDRBlock` | No / `10.0.0.0/24` | The CIDR block of the public A subnet.
 `PublicSubnetBCIDRBlock` | No / `10.0.1.0/24` | The CIDR block of the public B subnet.
 `PublicSubnetCCIDRBlock` | No / `10.0.2.0/24` | The CIDR block of the public C subnet.
 `PublicSubnetAIPv6CIDRBlock` | No | The IPv6 CIDR block of the public A subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `PublicSubnetBIPv6CIDRBlock` | No | The IPv6 CIDR block of the public B subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `PublicSubnetCIPv6CIDRBlock` | No | The IPv6 CIDR block of the public C subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `VPCId` | Yes | See the [VPC stack](#vpc) above.
 `VPNGatewayId` | No | See the [VPN stack](#vpn) above. Optional, if not specified, a VPN gateway will not be included in the public routing table.

<a name="asterisk">\*</a> Default values for these parameters can be supplied by the [`ipv6-defaults.sh`](#ipv6-defaults) scripts.

### Outputs

 Name | Description
---|---
 `JumpBoxPublicIPAddress` | The public IP address of the jump box.
 `NetworkACLId` | The id of the network access control list.
 `NATInstanceId` | The id of the NAT instance to be used in the private route table.
 `EgressOnlyInternetGatewayId` | The id of the IPv6 egress-only internet gateway.
 `PublicRouteTableId` | The id of the public routing table to be used in public subnets.

## Private Infrastructure

Creates network routing artifacts for private subnets.

| | |
---|---
 Definition | [`private.yml`](private.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/private.yml
 Script | [`scripts/private.sh`](scripts/private.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Required/Default | Description
---|---|---
 `NATInstanceId` | Yes | See the [public infrastructure stack](#public-infrastructure) above.
 `EgressOnlyInternetGatewayId` | Yes | See the [public infrastructure stack](#public-infrastructure) above.
 `VPCId` | Yes | See the [VPC stack](#vpc) above.
 `IPv6CIDRBlock` | No | The IPv6 CIDR block of the VPC. Optional, if not specified, no IPv6 capabilities will be configured.
 `VPNGatewayId` | No | See the [VPN stack](#vpn) above. Optional, if not specified, a VPN gateway will not be included in the private routing table.

### Outputs

 Name | Description
---|---
 `PrivateRouteTableId` | The id of the private routing table to be used in private subnets.

## Miscellaneous Scripts

### Full Stack

The full stack isn't really a stack but a set of convenience shell scripts for creating and deleting the [VPC](#vpc), [public infrastructure](#public-infrastructure), and [private infrastructure](#private-infrastructure) stacks in the proper order. Note that create script outputs several sets of environment variables that all need to be exported for use in other stacks. The create script itself handles passing the environment variables from one sub-script to another.

See [VPC](#vpc) above if IPv6 support is required (do not use these scripts for IPv6 support).

| | |
---|---
 Create Script | [`scripts/create-full-stack.sh`](scripts/create-full-stack.sh)
 Delete Script | [`scripts/delete-full-stack.sh`](scripts/delete-full-stack.sh)

### IPv6 Defaults

When configuring a VPC from the AWS console, an IPv6 `/56` CIDR block can be allocated. The `ipv6-defaults.sh` script takes the IPv6 CIDR block as an argument and returns several default parameters for configuring IPv6 resources.

Here is the actual output when calling the script (`./scripts/ipv6-defaults.sh 2600:52f9:4d75:2200::/56`):

```bash
export IPv6CIDRBlock=2600:52f9:4d75:2200::/56
export InternalAccessIPv6CIDRBlock=2600:52f9:4d75:2200::/56
export PublicSubnetAIPv6CIDRBlock=2600:52f9:4d75:2200::/64
export PublicSubnetBIPv6CIDRBlock=2600:52f9:4d75:2201::/64
export PublicSubnetCIPv6CIDRBlock=2600:52f9:4d75:2202::/64
```
