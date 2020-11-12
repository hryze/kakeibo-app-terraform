terraform {
  backend "s3" {
    bucket  = "kakeibo-tfstate"
    key     = "tfstate/terraform.tfstate"
    encrypt = true
    region  = "ap-northeast-1"
  }
}
