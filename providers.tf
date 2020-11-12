provider "aws" {
  region = var.default_region
}

provider "aws" {
  alias  = "virginia"
  region = var.acm_region
}
