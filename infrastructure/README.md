infrastructure
==============

Creates the core constructs starting with the VPC. This project is a prerequisite for all other projects.

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

3. **Public DNS Hosted Zone (optional):** Create a publicly accessible DNS hosted zone via the Route 53 console. The infrastructure project only uses this zone to create a DNS `A` record pointing to the `jump-box` instance (i.e.: `jump-box.prod.example.com` if [`StackEnv`](#stack-env) is set to `prod` and [`FullyQualifiedExternalParentDNSZone`](#fully-qualified-external-parent-dns-zone) is set to `example.com`). Also set `ExternalHostedZoneId` (TODO).

4. **Virtual Private Network (optional):** Deploy either an [AWS-compatible hardware or software VPN](https://aws.amazon.com/vpc/faqs/#C9). By doing so, the site of the VPN will have direct connectivity to your VPC without having to use the jump box.

# Stacks

## VPC

Just creates a VPC.

Note that because CloudFormation currently can't create a VPC with IPv6, this stack can't be used with the subsequent stacks if IPv6 support is required. Instead of using this stack, manually create a VPC with IPv6 support (via the console or CLI) then pass the `VPCId` and IPv6 parameters to the lower stacks. Note default IPv6 parameters are supplied by the [`ipv6-defaults.sh`](#ipv6-defaults) script.

| | |
---|---
 Definition | [`vpc.yml`](./vpc.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpc.yml
 Script | [`scripts/vpc.sh`](scripts/vpc.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `CIDRBlock` | `CIDR_BLOCK` | No / `10.0.0.0/16` | The CIDR of the entire VPC.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `VPCId` | `VPC_ID` | The id of the freshly created VPC.

## VPN

Creates network artifacts to route traffic through a VPN.

| | |
---|---
 Definition | [`vpn.yml`](./vpn.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpn.yml
 Script | [`scripts/vpn.sh`](scripts/vpn.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `BGPASNumber` | `BGP_AS_NUMBER` | No / `65000` | The Border Gateway Protocol Autonomous System Number.
 `CustomerGatewayIPAddress` | `CUSTOMER_GATEWAY_IP_ADDRESS` | Yes | The public IP address of the customer gateway. **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `InternalAccessCIDRBlock` | `INTERNAL_ACCESS_CIDR_BLOCK` | No / `10.0.0.0/8` | The CIDR block that can access internal interfaces of public resources.
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `VPNGatewayId` | `VPN_GATEWAY_ID` | The VPN gateway to which route tables will be connected via route propagation.

## External DNS

Creates an external DNS hosted zone. Note this is a separate stack as the public zone it creates can be shared among several full infrastructure stacks.

NOTE: This stack is not required by the other stacks. For instance, no public DNS records may be needed or desired and therefore no public domain name need be purchased.

| | |
---|---
 Definition | [`external-dns.yml`](./external-dns.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/external-dns.yml
 Script | [`scripts/external-dns.sh`](scripts/external-dns.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `FullyQualifiedExternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_EXTERNAL _PARENT_DNS_ZONE` (without space) | Yes | <a name="fully-qualified-external-parent-dns-zone">The</a> public DNS zone configured in Route 53 (should not start or end with .). **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `StackEnv` | `STACK_ENV` | Yes | See [`STACK_ENV`](../README.md#stack-env).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `ExternalHostedZoneId` | `EXTERNAL_HOSTED_ZONE_ID` | The id of the external DNS hosted zone.

## Internal DNS

Creates an internal DNS hosted zone. Note this is a separate stack as the private zone it creates can be shared among several full infrastructure stacks.

| | |
---|---
 Definition | [`internal-dns.yml`](./internal-dns.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/internal-dns.yml
 Script | [`scripts/internal-dns.sh`](scripts/internal-dns.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `FullyQualifiedExternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_EXTERNAL _PARENT_DNS_ZONE` (without space) | Yes | <a name="fully-qualified-external-parent-dns-zone">The</a> public DNS zone configured in Route 53 (should not start or end with .). **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `InternalDNSZone` | `INTERNAL_DNS_ZONE` | No / `internal` | The DNS zone prepended on a public DNS zone to hold internal DNS records.
 `StackEnv` | `STACK_ENV` | Yes | See [`STACK_ENV`](../README.md#stack-env).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `InternalHostedZoneId` | `INTERNAL_HOSTED_ZONE_ID` | The id of the internal DNS hosted zone.

## Public Infrastructure

Creates network routing artifacts for public subnets along with jump box and NAT instances.

| | |
---|---
 Definition | [`public.yml`](public.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/public.yml
 Script | [`scripts/public.sh`](scripts/public.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `AWSMusingsS3URL` | `AWS_MUSINGS_S3_URL` | No / (see [README](../README.md#environment-variables)) | The URL of the uploaded `aws-musings` artifacts on S3.
 `ExternalHostedZoneId` | `EXTERNAL_HOSTED_ZONE_ID` | No | <a name="external-hosted-zone-id">The</a> external DNS zone to which external DNS records will be added. Optional, external records will be created if specified.
 `FullyQualifiedExternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_EXTERNAL _PARENT_DNS_ZONE` (without space) | No | <a name="fully-qualified-external-parent-dns-zone">The</a> public DNS zone configured in Route 53 (should not start or end with .). Optional, external records will be created if specified. See the [External DNS stack](#external-dns) above.
 `InternalAccessCIDRBlock` | `INTERNAL_ACCESS_CIDR_BLOCK` | No / `10.0.0.0/8` | The CIDR block that can access internal interfaces of public resources.
 `InternalAccessIPv6CIDRBlock` | `INTERNAL_ACCESS_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block that can access internal interfaces of public resources. Optional, if not specified, no internal IPv6 access will be configured. [*](#asterisk)
 `InternalDNSZone` | `INTERNAL_DNS_ZONE` | No / `internal` | See the [Internal DNS stack](#internal-dns) above.
 `InternalHostedZoneId` | `INTERNAL_HOSTED_ZONE_ID` | Yes | See the [Internal DNS stack](#internal-dns) above.
 `InternalKeyName` | `INTERNAL_KEY_NAME` | No / `internal` | <a name="internal-key-name">The</a> SSH key pair used to connect to internal EC2 instances.
 `JumpBoxEIPAddress` | `JUMP_BOX_EIP_ADDRESS` | No | The Elastic IP address that will be assigned to the jump box instance. If not specified, a new EIP address will be allocated. By pre-allocating an EIP and specifying it via this parameter, the jump box will be accessible with the same address even though the infrastructure may have been rebuilt repeatedly.
 `JumpBoxKeyName` | `JUMP_BOX_KEY_NAME` | No / `jump-box` | <a name="jump-box-key-name">The</a> SSH key pair used to connect to the jump box EC2 instances.
 `JumpBoxSSHCIDRIP` | `JUMP_BOX_SSH_CIDR_IP` | No / `<current public ip>/32` | Any IP address included in this CIDR will be able to access the jump box via SSH (client must also use the `JumpBoxKeyName` SSH key pair). It is highly recommended to restrict this CIDR to only IP addresses that need to access the jump box. **DEFAULT VALUE MAY BE A SECURITY CONCERN**
 `JumpBoxInstanceType` | `JUMP_BOX_INSTANCE_TYPE` | No / `t2.nano` | The EC2 instance type of the jump box.
 `PublicSubnetACIDRBlock` | `PUBLIC_SUBNET_A_CIDR_BLOCK` | No / `10.0.0.0/24` | The CIDR block of the public A subnet.
 `PublicSubnetBCIDRBlock` | `PUBLIC_SUBNET_B_CIDR_BLOCK` | No / `10.0.1.0/24` | The CIDR block of the public B subnet.
 `PublicSubnetCCIDRBlock` | `PUBLIC_SUBNET_C_CIDR_BLOCK` | No / `10.0.2.0/24` | The CIDR block of the public C subnet.
 `PublicSubnetAIPv6CIDRBlock` | `PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the public A subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `PublicSubnetBIPv6CIDRBlock` | `PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the public B subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `PublicSubnetCIPv6CIDRBlock` | `PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the public C subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `StackEnv` | `STACK_ENV` | Yes | See [`STACK_ENV`](../README.md#stack-env).
 `StackOrg` | `STACK_ORG` | Yes | See [`STACK_ENV`](../README.md#stack-org).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.
 `VPNGatewayId` | `VPN_GATEWAY_ID` | No | See the [VPN stack](#vpn) above. Optional, if not specified, a VPN gateway will not be included in the public routing table.

<a name="asterisk">\*</a> Default values for these parameters can be supplied by the [`ipv6-defaults.sh`](#ipv6-defaults) scripts.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `JumpBoxPublicIPAddress` | `JUMP_BOX_PUBLIC_IP_ADDRESS` | The public IP address of the jump box.
 `NetworkACLId` | `NETWORK_ACL_ID` | The id of the network access control list.
 `NATInstanceId` | `NAT_INSTANCE_ID` | The id of the NAT instance to be used in the private route table.
 `EgressOnlyInternetGatewayId` | `EGRESS_ONLY_INTERNET_GATEWAY_ID` | The id of the IPv6 egress-only internet gateway.
 `PublicRouteTableId` | `PUBLIC_ROUTE_TABLE_ID` | The id of the public routing table to be used in public subnets.

## Private Infrastructure

Creates network routing artifacts for private subnets.

| | |
---|---
 Definition | [`private.yml`](private.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/private.yml
 Script | [`scripts/private.sh`](scripts/private.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `NATInstanceId` | `NAT_INSTANCE_ID` | Yes | See the [public infrastructure stack](#public-infrastructure) above.
 `EgressOnlyInternetGatewayId` | `EGRESS_ONLY_INTERNET_GATEWAY_ID` | Yes | See the [public infrastructure stack](#public-infrastructure) above.
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.
 `IPv6CIDRBlock` | `IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the VPC. Optional, if not specified, no IPv6 capabilities will be configured.
 `VPNGatewayId` | `VPN_GATEWAY_ID` | No | See the [VPN stack](#vpn) above. Optional, if not specified, a VPN gateway will not be included in the private routing table.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `PrivateRouteTableId` | `PRIVATE_ROUTE_TABLE_ID` | The id of the private routing table to be used in private subnets.

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
export IPV6_CIDR_BLOCK=2600:52f9:4d75:2200::/56
export INTERNAL_ACCESS_IPV6_CIDR_BLOCK=2600:52f9:4d75:2200::/56
export PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK=2600:52f9:4d75:2200::/64
export PUBLIC_SUBNET_B_IPV6_CIDR_BLOCK=2600:52f9:4d75:2201::/64
export PUBLIC_SUBNET_C_IPV6_CIDR_BLOCK=2600:52f9:4d75:2202::/64
```
