# iam-simple-ad-admin

Terraform module for creating IAM Role and Profile for attaching to an Active Directory (or SimpleAD) Administrator EC2 instance to give access to:

1) Register DNS record to Route53 for our ec2 host
2) SimpleAD-Admin get config files from S3
3) Cloudwatch logging and metrics
4) Send SNS messages for alerting
5) Get secret for simple-ad-admin admin password