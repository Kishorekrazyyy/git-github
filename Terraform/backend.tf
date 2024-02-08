terraform {
    backend "s3" {
      bucket = "kishorekrazy-s3-demo-krazy"
      region = "eu-north-1"
      key    = "kishore/terraform.tf state"
    }

}

