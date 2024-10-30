terraform {
  backend "s3" {
    bucket = "udemy-bucket-02"
    key = "path/to/mey/key"
    region = "ap-southeast-1"
  }
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">=5.11"
    }
  }
}



