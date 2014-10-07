Parameter scratch pad:

VPC instance:        vpc-f1a46b94

Steps to create:

1. Create stack https://s3-us-west-2.amazonaws.com/aws-musings/infrastructure-us-west-2/vpc.template
2. Manually create resources such as the VPN.
3. Create stack https://s3-us-west-2.amazonaws.com/aws-musings/infrastructure-us-west-2/infrastructure.template
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

NOTE: IF THE STACK IN STEP 3 IS BURNED DOWN, THE STACK IN STEP 1 WILL BE IN A BAD STATE.
RESET THE VPC'S DHCP OPTIONS BEFORE ATTEMPTING TO REBUILD THE STACK IN STEP 3!!!!!!!!!!!
