# Output values
#
output "simple_ad_admin_role" {
  value = aws_iam_role.simple-ad-admin
}
output "simple_ad_admin_profile" {
  value = aws_iam_instance_profile.simple-ad-admin
}