# NextJS ECS Terraform

This is a terraform project that creates a VPC, ECS cluster, and ECS service.

## Prerequisites

### Configure OIDC provider in AWS IAM
- Configure OIDC provider in AWS IAM: https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/
- Create a new IAM role for GitHub Actions to assume:


### Configure GitHub Actions

Add the following secrets to the repository:
- `AWS_ACCOUNT_ID`

### Configure Terraform 

```
terraform init
```

