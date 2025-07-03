resource "aws_lambda_layer_version" "jwt_layer" {
  layer_name          = "jwt-layer"
  compatible_runtimes = ["python3.9"]
  filename            = "build/lambda_layer.zip"
}

resource "aws_lambda_function" "authorizer" {
  function_name    = "${data.terraform_remote_state.global.outputs.project_name}-authorizer-${data.terraform_remote_state.global.outputs.environment}"
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler          = "authorizer.lambda_handler"
  runtime          = "python3.9"
  filename         = "build/authorizer.zip"
  source_code_hash = filebase64sha256("build/authorizer.zip")
  memory_size      = 128
  timeout          = 5

  layers = [aws_lambda_layer_version.jwt_layer.arn]

  environment {
    variables = {
      JWT_SECRET  = "${var.jwt_secret}"
      PYTHONPATH  = "/opt/python"
    }
  }
}