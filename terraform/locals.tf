data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  project_name = "measure-team"
  image_name   = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${data.aws_region.this.name}.amazonaws.com/${local.project_name}"
}
