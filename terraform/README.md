# Resources

ECR Module 
https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest



# Steps 

### What's a capacity provider? 
- A capacity provider is an abstraction layer on top of EC2 Autoscaling Groups. It allows you to specify how much capacity you want to allocate to FARGATE and FARGATE_SPOT. 
- when to create a new instance, based on the target capacity strategy.

### What's a target capacity strategy? 
- A target capacity strategy is a strategy that specifies how much capacity you want to allocate to FARGATE and FARGATE_SPOT. 
- It is a percentage of the total capacity that you want to allocate to FARGATE and FARGATE_SPOT. 
- The default target capacity strategy is 100% for FARGATE and 0% for FARGATE_SPOT. 
- The target capacity strategy is used to determine when to create a new instance, based on the target capacity strategy.
