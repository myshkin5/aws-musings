bosh-lite
=========

The bosh-lite sub-project contains two scripts: one for creating the bosh-lite infrastructure that is typically just run once and another to create a bosh-lite instance which can be run repeatedly on top of the bosh-lite infrastructure.

# Prerequisites

Outputs from the [infrastructure sub-project](../infrastructure) are required inputs for bosh-lite creation.

# Stacks

## bosh-lite-infrastructure

Creates a public subnet, a private subnet and security groups all used by bosh-lite instances and ELBs.

 | |
---|---
 Definition | [`bosh-lite-infrastructure.template`](./bosh-lite-infrastructure.template.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/bosh-lite/bosh-lite-infrastructure.template
 Create Script | [`scripts/create-bosh-lite-infrastructure.sh`](scripts/create-bosh-lite-infrastructure.sh)
 Delete Script | [`scripts/delete-bosh-lite-infrastructure.sh`](scripts/delete-bosh-lite-infrastructure.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `BOSHLiteAvailabilityZone` | `BOSH_LITE_AVAILABILITY_ZONE` | Yes / `us-east-1a` | The availability zone where the bosh-lite subnets and bosh-lite instances will be located.
 `BOSHLitePublicThree OctetCIDRBlock` (without space) | `BOSH_LITE_PUBLIC_THREE _OCTET_CIDR_BLOCK` (without space) | Yes / `10.0.7` | The CIDR of the public subnet.
 `BOSHLitePrivateThree OctetCIDRBlock` (without space) | `BOSH_LITE_PRIVATE_THREE _OCTET_CIDR_BLOCK` (without space) | Yes / `10.0.57` | The CIDR of the private subnet.
 `NetworkACLId` | `NETWORK_ACL_ID` | Yes | See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `PublicRouteTableId` | `PUBLIC_ROUTE_TABLE_ID` | Yes | See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `PrivateRouteTableId` | `PRIVATE_ROUTE_TABLE_ID` | Yes | See the [private infrastructure stack](../infrastructure#private-infrastructure).
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
 Definition | [`bosh-lite.template`](./bosh-lite.template.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/bosh-lite/bosh-lite.template
 Create Script | [`scripts/create-bosh-lite.sh`](scripts/create-bosh-lite.sh)
 Delete Script | [`scripts/delete-bosh-lite.sh`](scripts/delete-bosh-lite.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `AWSMusingsS3URL` | `AWS_MUSINGS_S3_URL` | Yes | See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `BOSHLiteCFAdminPassword` | `BOSH_LITE_CF_ADMIN_PASSWORD` | Yes | The password for the `admin` account to Cloud Foundry. **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `BOSHLiteELBSecurityGroupId` | `BOSH_LITE_ELB_SECURITY_GROUP_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteELBSecurityGroupId` | `BOSH_LITE_ELB_SECURITY_GROUP_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteELBSSLCertificateId` | `BOSH_LITE_ELB_SSL_CERTIFICATE_ID` | No | TODO: Not currently used. The ARN id of the SSL/TLS certificate used by the ELB to communicate with clients.
 `BOSHLiteImageId` | `BOSH_LITE_IMAGE_ID` | Yes / `ami-104a457a` | The Amazon Machine Image that will be used to create the bosh-lite image. Any bosh-lite AMI can be used (search Community AMIs for `boshlite-9000`).
 `BOSHLiteInstanceName` | `BOSH_LITE_INSTANCE_NAME` | Yes / `bosh-lite1` | The instance hostname. Also used in the `name` tag of artifacts created for the instance.
 `BOSHLiteInstance SecurityGroupId` (without space) | `BOSH_LITE_INSTANCE _SECURITY_GROUP_ID` (without space) | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteInstanceType` | `BOSH_LITE_INSTANCE_TYPE` | Yes / `m3.xlarge` | The instance type of the bosh-lite instance.
 `BOSHLitePublicSubnetId` | `BOSH_LITE_PUBLIC_SUBNET_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLitePrivateSubnetId` | `BOSH_LITE_PRIVATE_SUBNET_ID` | Yes | See the [bosh-lite-infrastructure](#bosh-lite-infrastructure) above.
 `BOSHLiteSpotPrice` | `BOSH_LITE_SPOT_PRICE` | Yes / `0.06` | The spot price in US dollars of the bosh-lite instance. 
 `DNSZone` | `DNS_ZONE` | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `FullyQualifiedExternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_EXTERNAL _PARENT_DNS_ZONE` (without space) | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure). Note this parameter was not required by the public infrastructure stack but it is required here. **REQUIRED, NO DEFAULT AND NOT SUPPLIED BY A PREVIOUS STACK**
 `FullyQualifiedInternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_INTERNAL _PARENT_DNS_ZONE` (without space) | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `InternalKeyName` | `INTERNAL_KEY_NAME` | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](../infrastructure#vpc).

### Post Creation Steps

After a bosh-lite instance has been created, the Cloud Foundry router is still not accessible to the outside world. Eventually the router should be automatically available via `iptables` configuration but until then, the following commands should be executed from a `root` terminal session:

```bash
IP_ADDR=$(ifconfig eth0 | grep "inet addr" | cut -d : -f 2 | cut -d \  -f 1)
ssh -L $IP_ADDR:443:10.244.0.34:443 localhost
```
