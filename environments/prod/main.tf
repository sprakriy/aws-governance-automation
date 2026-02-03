# 1. Call the Resource Auditor Module (The Muscle)
module "auditor" {
  source = "./terraform/modules/resource-auditor"
}

# 2. The EventBridge Rule (The Brain - Trigger every day)
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "daily-idle-resource-check"
  description         = "Triggers Lambda to check for unattached EBS volumes"
  schedule_expression = "cron(0 0 * * ? *)" # Midnight UTC
}

# 3. Connect the Rule to the Lambda
resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "TriggerAuditorLambda"
  arn       = module.auditor.lambda_function_arn
}

# 4. Permission for EventBridge to call Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.auditor.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}