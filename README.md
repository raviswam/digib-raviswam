# digib# digib-raviswam
     Install terraform , kops on the server
     Git clone  https://github.com/raviswam/digib-raviswam.git
    cd digib-raviswam
     ./main.sh

   Deploys the following
    2 S3 buckets  One for terraform tfstate
    Create VPC , private and public subnet (assumes region Is ap-southeast-1)
    Deploy HA EKS cluster (3 master , 3 slaves)

