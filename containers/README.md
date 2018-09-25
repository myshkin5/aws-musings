containers
==========

Builds a basic container framework using Fargate. TODO: Needs lots of updates!

# Stacks

## Public

Creates artifacts to support publicly facing applications.

| | |
---|---
 Definition | [`public.yml`](./public.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/containers/public.yml
 Script | [`scripts/public.sh`](scripts/public.sh)

### Parameters

 Name | Required/Default | Description
---|---|---
 `ContainersPublicSubnetACIDRBlock` | No / `10.0.3.0/24` | The CIDR block of the container public A subnet.
 `ContainersPublicSubnetBCIDRBlock` | No / `10.0.4.0/24` | The CIDR block of the container public B subnet.
 `ContainersPublicSubnetCCIDRBlock` | No / `10.0.5.0/24` | The CIDR block of the container public C subnet.
 `ContainersPublicSubnetAIPv6CIDRBlock` | No | The IPv6 CIDR block of the public A subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `ContainersPublicSubnetBIPv6CIDRBlock` | No | The IPv6 CIDR block of the public B subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `ContainersPublicSubnetCIPv6CIDRBlock` | No | The IPv6 CIDR block of the public C subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `NetworkACLId` | Yes | The id of the network access control list. See the `NetworkACLId` output of the [Public stack](../infrastructure#public-infrastructure).
 `PublicRouteTableId` | Yes | The id of the public routing table to be used in public subnets. See the `PublicRouteTableId` output of the [Public stack](../infrastructure#public-infrastructure).
 `VPCId` | Yes | See the `VPCId` output of the [VPC stack](../infrastructure#vpc).

<a name="asterisk">\*</a> Default values for these parameters can be supplied by the [`ipv6-defaults.sh`](#ipv6-defaults) scripts.

### Outputs

 Name | Description
---|---
 `ContainersPublicSubnetAId` | The id of the containers public subnet A.
 `ContainersPublicSubnetBId` | The id of the containers public subnet B.
 `ContainersPublicSubnetCId` | The id of the containers public subnet C.
 `ClusterARN` | The ARN of the cluster.
 `PublicLoadBalancerDNSName` | The DNS name of the public load balancer for use in alias record sets.
 `PublicLoadBalancerCanonicalHostedZoneId` | The hosted zone id of the public load balancer for use in alias record sets.
 `PublicLoadBalancerListenerARN` | The ARN of the public load balancer listener.

## Test Endpoint Repository - Example

Creates an ECR repository for deploying the [test endpoint app](tests/endpoint/src/main.go). All of the test endpoint stacks and scripts are included as an example of how to deploy services.

| | |
---|---
 Definition | [`test/repository.yml`](./test/repository.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/containers/test/repository.yml
 Script | [`scripts/test-endpoint-repository.sh`](scripts/test-endpoint-repository.sh)

### Parameters

 Name | Required/Default | Description
---|---|---
 `StackPrefix` | No / `<StackOrg>-<StackEnv>` | The prefix prepended to all aws-musings stacks.

## Test Endpoint Service - Example

Creates the [test endpoint app](tests/endpoint/src/main.go) service. All of the test endpoint stacks and scripts are included as an example of how to deploy services.

| | |
---|---
 Definition | [`test/service.yml`](./test/service.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/containers/test/service.yml
 Script | [`scripts/test-endpoint-service.sh`](scripts/test-endpoint-service.sh)

### Parameters

 Name | Required/Default | Description
---|---|---
 `ContainersSubnetAId` | Yes | The id of the containers subnet A.
 `ContainersSubnetBId` | Yes | The id of the containers subnet B.
 `ContainersSubnetCId` | Yes | The id of the containers subnet C.
 `ClusterARN` | Yes | The ARN of the cluster.
 `LoadBalancerDNSName` | Yes | The DNS name of the load balancer for use in alias records sets.
 `LoadBalancerCanonicalHostedZoneId` | Yes | The hosted zone id of the load balancer for use in alias record sets.
 `LoadBalancerListenerARN` | Yes | The ARN of the load balancer listener.
 `LoadBalancerListenerPriority` | No / `1` | The priority of the rule created on the load balancer listener (must be unique on the load balancer).
 `HostedZoneId` | Yes | The DNS zone to which a DNS A record will be added for the service.
 `FullyQualifiedDNSZone` | Yes | The DNS zone (should not start or end with .).
 `VPCId` | Yes | See the `VPCId` output of the [VPC stack](../infrastructure#vpc).
 `StackPrefix` | No / `<StackOrg>-<StackEnv>` | The prefix prepended to all aws-musings stacks.

## Miscellaneous Scripts

### IPv6 Defaults

When configuring a VPC from the AWS console, an IPv6 `/56` CIDR block can be allocated. The `ipv6-defaults.sh` script takes the IPv6 CIDR block as an argument and returns several default parameters for configuring IPv6 resources.

Here is the actual output when calling the script (`./scripts/ipv6-defaults.sh 2600:52f9:4d75:2200::/56`):

```bash
export ContainersPublicSubnetAIPv6CIDRBlock=2600:52f9:4d75:2203::/64
export ContainersPublicSubnetBIPv6CIDRBlock=2600:52f9:4d75:2204::/64
export ContainersPublicSubnetCIPv6CIDRBlock=2600:52f9:4d75:2205::/64
```

### Test Images

The test images scripts are used to either build and push Docker images to each service repository or delete all images from the same service repositories. The `build-test-images.sh` script should be invoked after the ECR repositories are created and before the test service stacks are created. The `delete-test-images.sh` script should be used to clear out the repositories prior to the repositories being deleted.

| | |
---|---
 Build Script | [`scripts/build-test-images.sh`](scripts/build-test-images.sh)
 Delete Script | [`scripts/delete-test-images.sh`](scripts/delete-test-images.sh)
