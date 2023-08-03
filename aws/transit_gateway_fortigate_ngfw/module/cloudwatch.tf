# Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  name              = "${var.network_prefix}_cloudwatch_log_grp"
  skip_destroy      = false
  retention_in_days = var.cloud_watch_params.retention_in_days
}

# IAM Role and Role Policy for Flow Logs
resource "aws_iam_role" "flow_logs" {
  count              = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  name               = "${var.network_prefix}_flow_log_iam_role"
  assume_role_policy = var.iam_policy_assume_role.json
}

resource "aws_iam_role_policy" "flow_logs" {
  count  = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  name   = "${var.network_prefix}_flow_log_iam_policy"
  role   = aws_iam_role.flow_logs[0].id
  policy = var.iam_policy_flow_logs.json
}

# Cloudwatch Flow Logs - Firewall VPC
resource "aws_flow_log" "cloud_watch_firewall" {
  count           = var.cloud_watch_params.cloud_watch_on == true ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.firewall.id

}

# Cloudwatch Flow Logs - Spoke VPCs
resource "aws_flow_log" "cloud_watch_spoke" {
  for_each        = { for vpck, vpc in var.spoke_vpc_params : vpck => vpc if var.cloud_watch_params.cloud_watch_on == true }
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.spoke[each.key].id
}