terraform {
    backend "s3" {
        bucket = "jenkins-cicd-pipeline"
        region = "us-east-1"
        key = "eks-cluster-automation/terraform.tfstate"
      
    }
}
