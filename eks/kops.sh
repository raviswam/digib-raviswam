#!/bin/bash
#kops get cluster --name eks. --state s3://tfstate-digib
kops create cluster \
--name eks.digib.raviswam.com \
--dns  private \
--state s3://tfstate-digib/eks.tfstate \
--cloud aws \
--master-size t2.medium \
--master-count 3 \
--master-zones ap-southeast-1a,ap-southeast-1b \
--node-size t2.medium \
--node-count 3 \
--zones ap-southeast-1a,ap-southeast-1c \
--ssh-public-key ~/.ssh/id_rsa.pub --yes 


# kops delete cluster --name training.aws.daas360cloud.com --state s3://tfstate-digib --yes
#kops delete secret --name <clustername> sshpublickey admin
#kops create secret --name <clustername> sshpublickey admin -i ~/.ssh/newkey.pub
#kops update cluster --yes to reconfigure the auto-scaling groups
#kops rolling-update cluster --name <clustername> --yes to immediately roll all the machines so they have the new key
#kops delete cluster training.aws.daas360cloud.com --state s3://tfstate-digib --yes
