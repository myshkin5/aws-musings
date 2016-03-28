bosh-lite
=========

The bosh-lite sub-project contains two scripts: one for creating the bosh-lite infrastructure that is typically just run once and another to create a bosh-lite instance which can be run repeatedly on top of the infrastructure.

# Prerequisites

Outputs from the [infrastructure sub-project](../infrastructure) are required inputs for bosh-lite creation.

# Stacks

## bosh-lite-infrastructure

Creates a public subnet , a private subnet and security groups all used by bosh-lite instances and ELBs.

 | |
---|---
 Definition | [`bosh-lite-infrastructure.template`](./bosh-lite-infrastructure.template)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/bosh-lite/bosh-lite-infrastructure.template
 Create Script | [`scripts/create-bosh-lite-infrastructure.sh`](scripts/create-bosh-lite-infrastructure.sh)
 Delete Script | [`scripts/delete-bosh-lite-infrastructure.sh`](scripts/delete-bosh-lite-infrastructure.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `BOSHLiteAvailabilityZone` | `BOSH_LITE_AVAILABILITY_ZONE` | Yes / `us-east-1a` | The availability zone where the bosh-lite subnets and bosh-lite instances will be located.
 `BOSHLitePublicThreeOctetCIDRBlock` | `BOSH_LITE_PUBLIC_THREE_OCTET_CIDR_BLOCK` | Yes / `10.0.7` | The CIDR of the public subnet.
 `BOSHLitePrivateThreeOctetCIDRBlock` | `BOSH_LITE_PRIVATE_THREE_OCTET_CIDR_BLOCK` | Yes / `10.0.57` | The CIDR of the private subnet.
 `NetworkACLId` | `NETWORK_ACL_ID` | Yes | See the [public infrastructure stack](../infrastructure#private-infrastructure).
 `PublicRouteTableId` | `PUBLIC_ROUTE_TABLE_ID` | Yes | See the [public infrastructure stack](../infrastructure#private-infrastructure).
 `PrivateRouteTableId` | `PRIVATE_ROUTE_TABLE_ID` | Yes | See the [private infrastructure stack](../infrastructure#public-infrastructure).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](../infrastructure#vpc).

### Outputs
 Name | Environment Variable | Description
---|---|---
 `BOSHLiteELBSecurityGroupId` | `BOSH_LITE_ELB_SECURITY_GROUP_ID` | The id of the security group to be assigned to bosh-lite ELBs.
 `BOSHLiteInstanceSecurityGroupId` | `BOSH_LITE_INSTANCE_SECURITY_GROUP_ID` | The id of the security group to be assigned to bosh-lite instances.
 `BOSHLitePrivateSubnetId` | `BOSH_LITE_PRIVATE_SUBNET_ID` | The id of the private subnet which will contain bosh-lite instances.
 `BOSHLitePublicSubnetId` | `BOSH_LITE_PUBLIC_SUBNET_ID` | The id of the public subnet which will contain bosh-lite ELBs.

## bosh-lite

Creates a single bosh-lite instance.

 | |
---|---
 Definition | [`bosh-lite.template`](./bosh-lite.template)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/bosh-lite/bosh-lite.template
 Create Script | [`scripts/create-bosh-lite.sh`](scripts/create-bosh-lite.sh)
 Delete Script | [`scripts/delete-bosh-lite.sh`](scripts/delete-bosh-lite.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `AWSMusingsS3URL` | `AWS_MUSINGS_S3_URL` | Yes / (see [README](../README.md#environment-variables)) |
 `BOSHLiteELBSecurityGroupId` | `BOSH_LITE_ELB_SECURITY_GROUP_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteELBSecurityGroupId` | `BOSH_LITE_ELB_SECURITY_GROUP_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteELBSSLCertificateId` | `BOSH_LITE_ELB_SSL_CERTIFICATE_ID` | No | TODO: Not currently used. The ARN id of the SSL/TLS certificate used by the ELB to communicate with clients.
 `BOSHLiteImageId` | `BOSH_LITE_IMAGE_ID` | Yes / `ami-104a457a` | The Amazon Machine Image that will be used to create the bosh-lite image. Any bosh-lite AMI can be used (search Community AMIs for `boshlite-9000`).
 `BOSHLiteInstanceName` | `BOSH_LITE_INSTANCE_NAME` | Yes / `bosh-lite1` | The instance hostname. Also used in the `name` tag of artifacts created for the instance.
 `BOSHLiteInstanceSecurityGroupId` | `BOSH_LITE_INSTANCE_SECURITY_GROUP_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteInstanceType` | `BOSH_LITE_INSTANCE_TYPE` | Yes / `m3.xlarge` | The instance type of the bosh-lite instance.
 `BOSHLitePublicSubnetId` | `BOSH_LITE_PUBLIC_SUBNET_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLitePrivateSubnetId` | `BOSH_LITE_PRIVATE_SUBNET_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteSpotPrice` | `BOSH_LITE_SPOT_PRICE` | Yes / `0.06` | The spot price in US dollars of the bosh-lite instance. 
 `DNSZone` | `DNS_ZONE` | Yes / `dev` |  See the [public infrastructure stack](../infrastructure#private-infrastructure).
 `FullyQualifiedExternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_EXTERNAL _PARENT_DNS_ZONE` (without space) | Yes |  See the [public infrastructure stack](../infrastructure#private-infrastructure).
 `FullyQualifiedInternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_INTERNAL _PARENT_DNS_ZONE` (without space) | Yes / `compute.local` |  See the [public infrastructure stack](../infrastructure#private-infrastructure).
 `InternalKeyName` | `INTERNAL_KEY_NAME` | Yes / `internal` |  See the [public infrastructure stack](../infrastructure#private-infrastructure).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](#vpc).

### Post Creation Steps

After a bosh-lite instance has been created, the Cloud Foundry router is still not accessible to the outside world. Eventually the router should be automatically available via `iptables` configuration but until then, the following commands should be executed from a `root` terminal session:
    ```bash
    IP_ADDR=$(ifconfig eth0 | grep "inet addr" | cut -d : -f 2 | cut -d \  -f 1)
    ssh -L $IP_ADDR:443:10.244.0.34:443 localhost
    ```

_*IMPORTANT:*_ The `cf` command line `admin` password defaults to `admin`.

