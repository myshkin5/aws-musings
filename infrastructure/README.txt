Steps to create:

1. Create VPC stack:
    https://s3-us-west-2.amazonaws.com/aws-musings/infrastructure/vpc.template

2. Create VPN stack:
    https://s3-us-west-2.amazonaws.com/aws-musings/infrastructure/vpn.template

3. Create Public Infrastructure stack:
    https://s3-us-west-2.amazonaws.com/aws-musings/infrastructure/public-infrastructure.template

    Parameter scratch pad:

        Virtual Private Gateway: vgw-7c3be762

    NOTE: IF THE STACK IN STEP 3 IS BURNED DOWN, THE STACK IN STEP 1 WILL BE IN A BAD STATE.
    RESET THE VPC'S DHCP OPTIONS BEFORE ATTEMPTING TO REBUILD THE STACK IN STEP 3!!!!!!!!!!!

    Burning down the step 3 stack sets the DHCP options to 'default' which probably doesn't
    really exist. Set the DHCP options back to the DHCP options created by AWS (one with
    domain-name-servers = AmazonProvidedDNS).

4. On the EC2 console select the NAT instance -> Actions -> Change Source/Dest. Check -> Yes, Disable.
    NOTE: No known fix for CF scripts. May be other scripting solutions.

5. On the bastion server install the internal ssh key:
    $ vi ~/.ssh/id_rsa       # Paste in key to new file
    $ chmod go-wrx ~/.ssh/id_rsa

6. Connect to DNS instance and execute the following:
    $ sudo chown named:named /var/log/named
    TODO: CF init should be able to resolve the chown issue eventually.

7. Restarting is only necessary to make the previous change take effect.
    $ sudo /etc/init.d/named restart

8. Create Private Infrastructure stack:
    https://s3-us-west-2.amazonaws.com/aws-musings/infrastructure/private-infrastructure.template

    Parameter scratch pad:

        NAT instance id:         i-5d7f4c51
        Network ACL id:          acl-da8336bf
        Virtual Private Gateway: vgw-7c3be762
