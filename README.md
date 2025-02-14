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

### Next.js Server Endpoint 

```
curl -f <application_load_balancer_url>/api/healthcheck
```

example response:
```
{
  "status": "ok",
  "timestamp": "2025-02-14T02:36:03.758Z",
  "uptime": 313.788692672,
  "memoryUsage": {
    "rss": 77361152,
    "heapTotal": 25075712,
    "heapUsed": 24334784,
    "external": 3904917,
    "arrayBuffers": 508617
  },
  "cpuUsage": {
    "user": 899842,
    "system": 170718
  },
  "pid": 1
}
```

### S3 Backend State

Create an S3 bucket to store the terraform state file.

```
aws s3 mb s3://state-nextjs-ecs-terraform-$RANDOM
```

