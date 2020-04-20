#!/bin/sh
log()
{
   echo "executing $1 now .........$(date)"
   echo "executing $1 now .........$(date)" >> ${execution_log}
}
Initialization()
{
   log ${FUNCNAME[0]}
   BASE_DIR=$(pwd)
   logs_dir=${BASE_DIR}/log
   DT=$(date '+%Y%m%d')
   execution_log=${logs_dir}/eks_cluster_logs_${DT}.log
   tfstate_dir=$BASE_DIR/tfstate
   vpc_dir=$BASE_DIR/vpc
   eks_dir=$BASE_DIR/eks
   mod_dir=$BASE_DIR/modules
   TERRAFORM="terraform"
   KOPS="kops"
   S3tfstate_file="s3://tfstate-digib/terraform.tfstate"
}
create_state_bucket()
{
   log ${FUNCNAME[0]}
   cd $tfstate_dir
   ${TERRAFORM} init
   ${TERRAFORM} plan 
   ${TERRAFORM} apply -auto-approve
}
create_vpc()
{
   log ${FUNCNAME[0]}
   cd $vpc_dir
   ${TERRAFORM} init
   ${TERRAFORM} plan 
   ${TERRAFORM} apply -auto-approve -state=${S3tfstate_file}

}
create_eks()
{
   log ${FUNCNAME[0]}
   cd $eks_dir
   ./kops.sh
}
InstallAwsVpcModule()
{

   log ${FUNCNAME[0]}
   cd $eks_dir
   git clone https://github.com/terraform-aws-modules/terraform-aws-vpc.git
}

main()
{
   log ${FUNCNAME[0]}
   Initialization
   InstallAwsVpcModule
   create_state_bucket
   create_vpc
   create_eks
}
main
