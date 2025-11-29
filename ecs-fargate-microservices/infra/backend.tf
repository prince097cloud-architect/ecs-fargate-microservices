terraform {
  backend "remote" {
    organization = "TFE-PROD-GRADE-INFRA"

    workspaces {
      name = "ecs-serverless-infra-poc"
    }
  }
}
