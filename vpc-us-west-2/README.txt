Accessible after upload from https://s3-us-west-2.amazonaws.com/aws-musings/vpc-us-west-2/vpc.template

Post creation steps:

1. On the EC2 console select the NAT instance -> Actions -> Change Source/Dest. Check -> Yes, Disable.
    NOTE: No known fix for CF scripts. May be other scripting solutions.
2. On the bastion server install the internal ssh key:
    $ vi ~/.ssh/id_rsa       # Paste in key to new file
    $ chmod go-wrx ~/.ssh/id_rsa
3. Connect to NAT instance via ssh and execute the following:
    $ sudo /etc/init.d/named start
    TODO: CF init should be able to resolve this eventually.
