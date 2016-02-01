Steps to create:

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
