Accessible after upload from https://s3-us-west-2.amazonaws.com/aws-musings/vpc-us-west-2/vpc.template

Post creation steps:

1. On the EC2 console select the NAT instance -> Actions -> Change Source/Dest. Check -> Yes, Disable.
    NOTE: No known fix for CF scripts. May be other scripting solutions.
2. On the bastion server install the internal ssh key:
    $ vi ~/.ssh/id_rsa       # Paste in key to new file
    $ chmod go-wrx ~/.ssh/id_rsa
3. Connect to DNS instance and execute the following:
    $ sudo chown named:named /var/log/named
    TODO: CF init should be able to resolve the chown issue eventually.
4. Also on the DNS instance update the /var/named/dynamic files with the DNS instance's
    IP address (see notes in the files for more details):
    $ sudo vi /var/named/dynamic/named.vpc
    $ sudo vi /var/named/dynamic/named.vpc-rev
5. Restarting is only necessary to make the previous changes take effect.
    $ sudo /etc/init.d/named restart
