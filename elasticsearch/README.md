elasticsearch
=============

The elasticsearch sub-project contains two scripts: one for creating the elasticsearch infrastructure that is typically just run once and another to create an elasticsearch instance which can be run repeatedly on top of the elasticsearch infrastructure.

# Prerequisites

Outputs from the [infrastructure sub-project](../infrastructure) are required inputs for elasticsearch creation.

# Stacks

## elasticsearch-infrastructure

Creates a private subnet and security groups used by elasticsearch instances.

| | |
---|---
 Definition | [`elasticsearch-infrastructure.yml`](./elasticsearch-infrastructure.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/elasticsearch/elasticsearch-infrastructure.yml
 Create Script | [`scripts/create-elasticsearch-infrastructure.sh`](scripts/create-elasticsearch-infrastructure.sh)
 Delete Script | [`scripts/delete-elasticsearch-infrastructure.sh`](scripts/delete-elasticsearch-infrastructure.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `ElasticsearchAvailabilityZone` | `ELASTICSEARCH_LITE_AVAILABILITY_ZONE` | Yes / `us-east-1a` | The availability zone where the elasticsearch subnets and elasticsearch instances will be located.
 `ElasticsearchPrivateThree OctetCIDRBlock` (without space) | `ELASTICSEARCH_PRIVATE_THREE _OCTET_CIDR_BLOCK` (without space) | Yes / `10.0.57` | The CIDR of the private subnet.
 `NetworkACLId` | `NETWORK_ACL_ID` | Yes | See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `PrivateRouteTableId` | `PRIVATE_ROUTE_TABLE_ID` | Yes | See the [private infrastructure stack](../infrastructure#private-infrastructure).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](../infrastructure#vpc).

### Outputs
 Name | Environment Variable | Description
---|---|---
 `ElasticsearchInstanceSecurityGroupId` | `ELASTICSEARCH_INSTANCE_SECURITY_GROUP_ID` | The id of the security group to be assigned to elasticsearch instances.
 `ElasticsearchPrivateSubnetId` | `ELASTICSEARCH_PRIVATE_SUBNET_ID` | The id of the private subnet which will contain elasticsearch instances.

## elasticsearch

Creates a single elasticsearch instance.

| | |
---|---
 Definition | [`elasticsearch.yml`](./elasticsearch.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/elasticsearch/elasticsearch.yml
 Create Script | [`scripts/create-elasticsearch.sh`](scripts/create-elasticsearch.sh)
 Delete Script | [`scripts/delete-elasticsearch.sh`](scripts/delete-elasticsearch.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `AWSMusingsS3URL` | `AWS_MUSINGS_S3_URL` | Yes | See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `ElasticsearchImageId` | `ELASTICSEARCH_IMAGE_ID` | Yes / `ami-104a457a` | The Amazon Machine Image that will be used to create the elasticsearch image.
 `ElasticsearchInstanceName` | `ELASTICSEARCH_INSTANCE_NAME` | Yes / `elasticsearch1` | The instance hostname. Also used in the `name` tag of artifacts created for the instance.
 `ElasticsearchInstance SecurityGroupId` (without space) | `ELASTICSEARCH_INSTANCE _SECURITY_GROUP_ID` (without space) | Yes | See the [elasticsearch-infrastructure](#elasticsearch-infrastructure) above.
 `ElasticsearchInstanceType` | `ELASTICSEARCH_INSTANCE_TYPE` | Yes / `m3.xlarge` | The instance type of the elasticsearch instance.
 `ElasticsearchPrivateSubnetId` | `ELASTICSEARCH_PRIVATE_SUBNET_ID` | Yes | See the [elasticsearch-infrastructure](#elasticsearch-infrastructure) above.
 `ElasticsearchSpotPrice` | `ELASTICSEARCH_SPOT_PRICE` | Yes / `0.06` | The spot price in US dollars of the elasticsearch instance. 
 `DNSZone` | `DNS_ZONE` | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `FullyQualifiedInternal ParentDNSZone` (without space) | `FULLY_QUALIFIED_INTERNAL _PARENT_DNS_ZONE` (without space) | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `InternalKeyName` | `INTERNAL_KEY_NAME` | Yes |  See the [public infrastructure stack](../infrastructure#public-infrastructure).
 `VPCId` | `VPC_ID` | Yes | See the [VPC stack](../infrastructure#vpc).
