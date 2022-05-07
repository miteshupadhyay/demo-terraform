#--------------------------------------------------------------------------------
# This Backend file is responsible to keep the state file into remote repository.
#
#         ************ NEVER CHANGE BELOW CONFIGURATIONS **************
#         ****** THIS IS ONE TIME INITIAL LEVEL CONFIGURATIONS ********
#
#--------------------------------------------------------------------------------


terraform {
  backend "s3" {

    # Bucket where Terraform State File will get stored.
    bucket = "dealer-service-terraform-remote-state"

    # This Ensures that the State file is Stored Encrypted at Rest in S3.
    encrypt = true

    # This will be used as a folder in which you store the state file.
    workspace_key_prefix = "dealerserviceapi"

    # Region of the S3 Bucket
    region = "ap-south-1"

    # This key would be state file's File Name
    key = "dealer-service-ecs-dev"
  }
}