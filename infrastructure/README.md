infrastructure
==============

Creates the core constructs starting with the VPC. This project is a prerequisite for all other projects.

# Prerequisites

1. **Jump Box SSH Key Pair:** Via the EC2 console, create or import an SSH key pair named `jump-box`. If an alternate name is used, specify the name via the [`JumpBoxKeyName`](#jump-box-key-name) parameter. This SSH key is only used to connect to the `jump-box` instance from the open Internet so distribute it carefully.

    **Note:** For convenience the following `$HOME/.ssh/config` file can be used to manage the jump box SSH key (assumes the `jump-box` private key is stored in `$HOME/.ssh/id_rsa_jump_box` with [`DNSZone`](#dns-zone) and [`FullyQualifiedExternalParentDNSZone`](#fully-qualified-external-parent-dns-zone) set to `prod` and `example.com` respectively):
    ```
    Host jb jump-box jump-box.prod.example.com
      Hostname jump-box.prod.example.com
      User ubuntu
      IdentityFile ~/.ssh/id_rsa_jump_box
      ForwardAgent yes
    ```

2. **Internal SSH Key Pair:** Via the EC2 console, create or import an SSH key pair named `internal`. If an alternate name is used, specify the name via the [`InternalKeyName`](#internal-key-name) parameter. This SSH key is used to connect to all infrastructure instances except the `jump-box` instance.

    **Note:** Prior to `ssh`ing to the jump box, the internal key must be added to the SSH key forwarding agent using the following command (assumes the `internal` private key is stored in `$HOME/.ssh/id_rsa_internal`):
    ```bash
    ssh-add $HOME/.ssh/id_rsa_internal
    ```

3. **DNS Hosted Zone (optional):** Create a publicly accessible DNS hosted zone via the Route 53 console. The infrastructure project only uses this zone to create a DNS `A` record pointing to the `jump-box` instance (i.e.: `jump-box.prod.example.com` if [`DNSZone`](#dns-zone) is set to `prod` and [`FullyQualifiedExternalParentDNSZone`](#fully-qualified-external-parent-dns-zone) is set to `example.com`).

4. **Virtual Private Network (optional):** Deploy either an [AWS-compatible hardware or software VPN](https://aws.amazon.com/vpc/faqs/#C9). By doing so, the site of the VPN will have direct connectivity to your VPC without having to use the jump box.

# Stacks

## VPC

Just creates a VPC.

 | |
---|---
 Definition | [`vpc.template`](./vpc.template)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpc.template
 Create Script | [`scripts/create-vpc.sh`](scripts/create-vpc.sh) (also see [full stack](#full-stack))
 Delete Script | [`scripts/delete-vpc.sh`](scripts/delete-vpc.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `SecondOctet` | `SECOND_OCTET` | Yes / `0` | <a name="second-octet">The</a> second octet of CIDR of the entire VPC. The first octet is always `10` for a full CIDR of `10.0.0.0/16` (assuming `SecondOctet` is set to `0`).

### Outputs
 Name | Environment Variable | Description
---|---|---
 `VPCId` | `VPC_ID` | The id of the freshly created VPC.

## VPN

Creates network artifacts to route traffic through a VPN.

 | |
---|---
 Definition | [`vpn.template`](./vpn.template)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpn.template
 Create Script | [`scripts/create-vpn.sh`](scripts/create-vpn.sh)
 Delete Script | [`scripts/delete-vpn.sh`](scripts/delete-vpn.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `BGPASNumber` | `BGP_AS_NUMBER` | Yes / `65000` | The Border Gateway Protocol Autonomous System Number.
 `CustomerGatewayIPAddress` | `CUSTOMER_GATEWAY_IP_ADDRESS` | Yes | The public IP address of the customer gateway. **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.

### Outputs
 Name | Environment Variable | Description
---|---|---
 `VPNGatewayId` | `VPN_GATEWAY_ID` | The VPN gateway to which route tables will be connected via route propagation.

## Public Infrastructure

Creates network routing artifacts for public subnets along with jump box and NAT instances.

 | |
---|---
 Definition | [`public-infrastructure.template`](./public-infrastructure.template)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/public-infrastructure.template
 Create Script | [`scripts/create-public-infrastructure.sh`](scripts/create-public-infrastructure.sh) (also see [full stack](#full-stack))
 Delete Script | [`scripts/delete-public-infrastructure.sh`](scripts/delete-public-infrastructure.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `AWSMusingsS3URL` | `AWS_MUSINGS_S3_URL` | Yes / (see [README](../README.md#environment-variables)) | The URL of the uploaded `aws-musings` artifacts on S3.
 `DNSZone` | `DNS_ZONE` | Yes / `dev` | <a name="dns-zone">The</a> DNS zone within the external and internal DNS zones (i.e.: with an external DNS of `example.com`, the full external zone would be `dev.example.com`.
 `FullyQualifiedExternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_EXTERNAL _PARENT_DNS_ZONE` (without space) | No | <a name="fully-qualified-external-parent-dns-zone">The</a> public DNS zone configured in Route 53. If not specified, no public DNS record will be created for the jump box.
 `FullyQualifiedInternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_INTERNAL _PARENT_DNS_ZONE` (without space) | Yes / `compute.local` | The private DNS zone (parent zone to the `DNSZone` specified above.
 `InternalKeyName` | `INTERNAL_KEY_NAME` | Yes / `internal` | <a name="internal-key-name">The</a> SSH key pair used to connect to internal EC2 instances.
 `JumpBoxEIPAddress` | `JUMP_BOX_EIP_ADDRESS` | No | The Elastic IP address that will be assigned to the jump box instance. If not specified, a new EIP address will be allocated. By pre-allocating an EIP and specifying it via this parameter, the jump box will be accessible with the same address even though the infrastructure may have been rebuilt repeatedly.
 `JumpBoxKeyName` | `JUMP_BOX_KEY_NAME` | Yes / `jump-box` | <a name="jump-box-key-name">The</a> SSH key pair used to connect to the jump box EC2 instances.
 `JumpBoxSSHCIDRIP` | `JUMP_BOX_SSH_CIDR_IP` | Yes / `0.0.0.0/0` | Any IP address included in this CIDR will be able to access the jump box via SSH (client must also use the `JumpBoxKeyName` SSH key pair). It is highly recommended to restrict this CIDR to only IP addresses that need to access the jump box. **DEFAULT VALUE MAY BE A SECURITY CONCERN**
 `SecondOctet` | `SECOND_OCTET` | Yes | See the [VPC stack](#vpc) above.
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.
 `VPNGatewayId` | `VPN_GATEWAY_ID` | No | See the [VPN stack](#vpn) above. Optional, if not specified, a VPN gateway will not be included in the public routing table.

### Outputs
 Name | Environment Variable | Description
---|---|---
 `JumpBoxPublicIPAddress` | `JUMP_BOX_PUBLIC_IP_ADDRESS` | The public IP address of the jump box.
 `NetworkACLId` | `NETWORK_ACL_ID` | The id of the network access control list.
 `NATInstanceId` | `NAT_INSTANCE_ID` | The id of the NAT instance to be used in the private route table.
 `PublicRouteTableId` | `PUBLIC_ROUTE_TABLE_ID` | The id of the public routing table to be used in public subnets.

## Private Infrastructure

Creates network routing artifacts for private subnets.

 | |
---|---
 Definition | [`private-infrastructure.template`](./private-infrastructure.template)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/private-infrastructure.template
 Create Script | [`scripts/create-private-infrastructure.sh`](scripts/create-private-infrastructure.sh) (also see [full stack](#full-stack))
 Delete Script | [`scripts/delete-private-infrastructure.sh`](scripts/delete-private-infrastructure.sh) (also see [full stack](#full-stack))

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `NATInstanceId` | `NAT_INSTANCE_ID` | Yes | See the [public infrastructure stack](#public-infrastructure) above. 
 `NetworkACLId` | `NETWORK_ACL_ID` | Yes | See the [public infrastructure stack](#public-infrastructure) above.
 `SecondOctet` | `SECOND_OCTET` | Yes | See the [VPC stack](#vpc) above.
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc) above.
 `VPNGatewayId` | `VPN_GATEWAY_ID` | No | See the [VPN stack](#vpn) above. Optional, if not specified, a VPN gateway will not be included in the private routing table.

### Outputs
 Name | Environment Variable | Description
---|---|---
 `PrivateRouteTableId` | `PRIVATE_ROUTE_TABLE_ID` | The id of the private routing table to be used in private subnets.

## Full Stack

The full stack isn't really a stack but a set of convenience shell scripts for creating and deleting the [VPC](#vpc), [public infrastructure](#public-infrastructure), and [private infrastructure](#private-infrastructure) stacks in the proper order. Note that create script outputs several sets of environment variables that all need to be exported for use in other stacks. The create script itself handles passing the environment variables from one sub-script to another.

 | |
---|---
 Create Script | [`scripts/create-full-stack.sh`](scripts/create-full-stack.sh)
 Delete Script | [`scripts/delete-full-stack.sh`](scripts/delete-full-stack.sh)

<!---
DNS Notes (something here may be useful when resurrecting the DNS functionality)
1. Create VPC stack [`vpc.template`](./vpc.template) (S3 URL [here](https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpc.template).

2. Create VPN stack [`vpn.template`](./vpn.template) (optional, S3 URL [here](https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/vpn.template).

3. Create Public Infrastructure stack [`public-infrastructure.template`](./public-infrastructure.template) (S3 URL [here](https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/public-infrastructure.template).

  NOTE: IF THE STACK IN STEP 3 IS BURNED DOWN, THE STACK IN STEP 1 WILL BE IN A BAD STATE.
  RESET THE VPC'S DHCP OPTIONS BEFORE ATTEMPTING TO REBUILD THE STACK IN STEP 3!!!!!!!!!!!

  Burning down the step 3 stack sets the DHCP options to 'default' which probably doesn't
  really exist. Set the DHCP options back to the DHCP options created by AWS (one with
  domain-name-servers = AmazonProvidedDNS).

4. Connect to DNS instance and execute the following:

  ```bash
  sudo chown named:named /var/log/named
  ```

  TODO: CF init should be able to resolve the chown issue eventually.

5. Restarting is only necessary to make the previous change take effect.

  ```bash
  sudo /etc/init.d/named restart
  ```

6. Create Private Infrastructure stack [`private-infrastructure.template`](./private-infrastructure.template) (S3 URL [here](https://s3.amazonaws.com/aws-musings-us-east-1/infrastructure/private-infrastructure.template).
--->
