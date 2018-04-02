containers
==========

Builds a basic container framework using Fargate.

# Stacks

## Public

Creates artifacts to support publicly facing applications.

| | |
---|---
 Definition | [`public.yml`](./public.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/containers/public.yml
 Script | [`scripts/public.sh`](scripts/public.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `ContainersPublicSubnetACIDRBlock` | `CONTAINERS_PUBLIC_SUBNET_A_CIDR_BLOCK` | No / `10.0.3.0/24` | The CIDR block of the container public A subnet.
 `ContainersPublicSubnetBCIDRBlock` | `CONTAINERS_PUBLIC_SUBNET_B_CIDR_BLOCK` | No / `10.0.4.0/24` | The CIDR block of the container public B subnet.
 `ContainersPublicSubnetCCIDRBlock` | `CONTAINERS_PUBLIC_SUBNET_C_CIDR_BLOCK` | No / `10.0.5.0/24` | The CIDR block of the container public C subnet.
 `ContainersSubnetAIPv6CIDRBlock` | `CONTAINERS_SUBNET_A_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the public A subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `ContainersSubnetBIPv6CIDRBlock` | `CONTAINERS_SUBNET_A_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the public B subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `ContainersSubnetCIPv6CIDRBlock` | `CONTAINERS_SUBNET_A_IPV6_CIDR_BLOCK` | No | The IPv6 CIDR block of the public C subnet. Optional, if not specified, no IPv6 address are allocated. [*](#asterisk)
 `NetworkACLId` | `NETWORK_ACL_ID` | Yes | The id of the network access control list. See the `NetworkACLId` output of the [Public stack](../infrastructure#public-infrastructure).
 `PublicRouteTableId` | `PUBLIC_ROUTE_TABLE_ID` | Yes | The id of the public routing table to be used in public subnets. See the `PublicRouteTableId` output of the [Public stack](../infrastructure#public-infrastructure).
 `VPCId` | `VPC_ID` | Yes | See the `VPCId` output of the [VPC stack](../infrastructure#vpc).

<a name="asterisk">\*</a> Default values for these parameters can be supplied by the [`ipv6-defaults.sh`](#ipv6-defaults) scripts.

### Outputs

 Name | Environment Variable | Description
---|---|---
 `ContainersPublicSubnetAId` | `CONTAINERS_PUBLIC_SUBNET_A_ID` | The id of the containers public subnet A.
 `ContainersPublicSubnetBId` | `CONTAINERS_PUBLIC_SUBNET_B_ID` | The id of the containers public subnet B.
 `ContainersPublicSubnetCId` | `CONTAINERS_PUBLIC_SUBNET_C_ID` | The id of the containers public subnet C.
 `PublicClusterARN` | `PUBLIC_CLUSTER_ARN` | The ARN of the public cluster.
 `PublicLoadBalancerDNSName` | `PUBLIC_LOAD_BALANCER_DNS_NAME` | The DNS name of the public load balancer for use in alias record sets.
 `PublicLoadBalancerCanonicalHostedZoneId` | `PUBLIC_LOAD_BALANCER_CANONICAL_HOSTED_ZONE_ID` | The hosted zone id of the public load balancer for use in alias record sets.
 `PublicLoadBalancerListenerARN` | `PUBLIC_LOAD_BALANCER_LISTENER_ARN` | The ARN of the public load balancer listener.

## Test Endpoint Repository - Example

Creates an ECR repository for deploying the [test endpoint app](tests/endpoint/src/main.go). All of the test endpoint stacks and scripts are included as an example of how to deploy services.

| | |
---|---
 Definition | [`test/repository.yml`](./test/repository.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/containers/test/repository.yml
 Script | [`scripts/test-endpoint-repository.sh`](scripts/test-endpoint-repository.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `StackPrefix` | `STACK_PREFIX` | No / `<STACK_ORG>-<STACK_ENV>` | The prefix prepended to all aws-musings stacks.

## Test Endpoint Service - Example

Creates the [test endpoint app](tests/endpoint/src/main.go) service. All of the test endpoint stacks and scripts are included as an example of how to deploy services.

| | |
---|---
 Definition | [`test/service.yml`](./test/service.yml)
 S3 URL | https://s3.amazonaws.com/aws-musings-us-east-1/containers/test/service.yml
 Script | [`scripts/test-endpoint-service.sh`](scripts/test-endpoint-service.sh)

### Parameters

 Name | Environment Variable | Required/Default | Description
---|---|---|---
 `ContainersSubnetAId` | Various | Yes | The id of the containers subnet A.
 `ContainersSubnetBId` | Various | Yes | The id of the containers subnet B.
 `ContainersSubnetCId` | Various | Yes | The id of the containers subnet C.
 `ClusterARN` | Various | Yes | The ARN of the cluster.
 `LoadBalancerDNSName` | Various | Yes | The DNS name of the load balancer for use in alias records sets.
 `LoadBalancerCanonicalHostedZoneId` | Various | Yes | The hosted zone id of the load balancer for use in alias record sets.
 `LoadBalancerListenerARN` | Various | Yes | The ARN of the load balancer listener.
 `LoadBalancerListenerPriority` | `LOAD_BALANCER_LISTENER_PRIORITY` | No / `1` | The priority of the rule created on the load balancer listener (must be unique on the load balancer).
 `HostedZoneId` | Various | Yes | The DNS zone to which a DNS A record will be added for the service.
 `FullyQualifiedDNSZone` | Various | Yes | The DNS zone (should not start or end with .).
 `VPCId` | `VPC_ID` | Yes | See the `VPCId` output of the [VPC stack](../infrastructure#vpc).
 `StackPrefix` | `STACK_PREFIX` | No / `<STACK_ORG>-<STACK_ENV>` | The prefix prepended to all aws-musings stacks.

## Miscellaneous Scripts

### IPv6 Defaults

When configuring a VPC from the AWS console, an IPv6 `/56` CIDR block can be allocated. The `ipv6-defaults.sh` script takes the IPv6 CIDR block as an argument and returns several default parameters for configuring IPv6 resources.

Here is the actual output when calling the script (`./scripts/ipv6-defaults.sh 2600:52f9:4d75:2200::/56`):

```bash
export CONTAINERS_PUBLIC_SUBNET_A_IPV6_CIDR_BLOCK=2600:52f9:4d75:2200::/64
export CONTAINERS_PUBLIC_SUBNET_B_IPV6_CIDR_BLOCK=2600:52f9:4d75:2201::/64
export CONTAINERS_PUBLIC_SUBNET_C_IPV6_CIDR_BLOCK=2600:52f9:4d75:2202::/64
```

### Test Images

The test images scripts are used to either build and push Docker images to each service repository or delete all images from the same service repositories. The `build-test-images.sh` script should be invoked after the ECR repositories are created and before the test service stacks are created. The `delete-test-images.sh` script should be used to clear out the repositories prior to the repositories being deleted.

| | |
---|---
 Build Script | [`scripts/build-test-images.sh`](scripts/build-test-images.sh)
 Delete Script | [`scripts/delete-test-images.sh`](scripts/delete-test-images.sh)
