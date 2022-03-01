# ---------------------------------------------------------------------------------------------------------------------
# IAM Role for use by an EC2 instance of SimpleAD-Admin to give access to :
#   1) Register DNS record to Route53 for our ec2 host
#   2) SimpleAD-Admin get config files from S3
#   3) Cloudwatch logging and metrics
#   4) Send SNS messages for alerting
#   5) Get secret for simple-ad-admin admin password
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "simple-ad-admin" {
  name                 = "${var.resource_name_prefix}-simple-ad-admin"
  max_session_duration = 43200
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags                 = var.tags
}

# 1) Register DNS record to Route53 for our ec2 host
resource "aws_iam_policy" "route53" {
  name        = "${var.resource_name_prefix}-simple-ad-admin-route53"
  description = "RegisterDNSwithRoute53"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Route53registerDNS",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:GetHostedZone",
        "route53:ListResourceRecordSets"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:route53:::hostedzone/${var.route53_private_zone_id}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "route53" {
  role       = aws_iam_role.simple-ad-admin.name
  policy_arn = aws_iam_policy.route53.arn
}

# 2) SimpleAD-Admin get config files from S3
resource "aws_iam_policy" "simple-ad-admin-s3" {
  name        = "${var.resource_name_prefix}-simple-ad-admin-s3"
  description = "Read access to s3 bucket for SimpleAD-Admin config files"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SimpleADAdminReadS3",
      "Action": [
        "s3:List*",
        "s3:GetObject*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "simple-ad-admin-s3" {
  role       = aws_iam_role.simple-ad-admin.name
  policy_arn = aws_iam_policy.simple-ad-admin-s3.arn
}

# 3) Cloudwatch logging and metrics - To allow output of metrics and logs to Cloudwatch
resource "aws_iam_role_policy_attachment" "simple-ad-admin-cloudwatch" {
  role       = aws_iam_role.simple-ad-admin.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# 4) Send SNS messages for alerting
resource "aws_iam_policy" "simple-ad-admin-sns" {
  name        = "${var.resource_name_prefix}-simple-ad-admin-sns"
  description = "Add ability to send SNS alert message"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "simple-ad-admin-sns" {
  role       = aws_iam_role.simple-ad-admin.name
  policy_arn = aws_iam_policy.simple-ad-admin-sns.arn
}

# 5) Get secret for simple-ad-admin admin password
resource "aws_iam_policy" "simple-ad-admin-get-secrets" {
  name        = "${var.resource_name_prefix}-simple-ad-admin-get-secrets"
  description = "Get secret for simple-ad-admin admin password"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "GetSecretsForSimpleADAdmin"
        Effect    = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_arns
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "simple-ad-admin-get-secrets" {
  role       = aws_iam_role.simple-ad-admin.name
  policy_arn = aws_iam_policy.simple-ad-admin-get-secrets.arn
}


resource "aws_iam_instance_profile" "simple-ad-admin" {
  name = "simple-ad-admin"
  role = aws_iam_role.simple-ad-admin.name
}
