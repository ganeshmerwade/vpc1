provider "aws" {
    region = var.root_region
      endpoints {
    sts = "https://sts.us-east-1.amazonaws.com"
}
}