terraform {
  backend "gcs" {
    bucket = "serverless-devsecops-460587643228-tf-state"
    prefix = "terraform/state"
  }
}