# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

data "archive_file" "userfunctions_lambda_auth_zip" {
  source_dir = "src/authorizer/"
  output_path = "/tmp/userfunctions_lambda_auth.zip"
  type        = "zip"
  depends_on  = [null_resource.build_dependencies_authorizer]
}

resource "null_resource" "build_dependencies_authorizer" {
  provisioner "local-exec" {
    command = "python3 -m pip install -r src/authorizer/requirements.txt -t src/authorizer/ --no-user"
    }
    
  triggers = {
    dependencies = filemd5("src/authorizer/requirements.txt")
    source = filemd5("src/authorizer/lambda_function.py")
  }
}

resource "aws_lambda_function" "userfunctions_lambda_auth" {
  filename      = "${data.archive_file.userfunctions_lambda_auth_zip.output_path}"
  function_name = "${var.workshop_stack_base_name}_userfunctions_lambda_auth"
  description   = "Handler for Lambda authorizer"
  role          = "${aws_iam_role.userfunctions_lambda_auth_role.arn}"
  handler       = "lambda_function.lambda_handler"
  source_code_hash = "${data.archive_file.userfunctions_lambda_auth_zip.output_base64sha256}"
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout
  environment {
    variables = {
      USER_POOL_ID = aws_cognito_user_pool.user_pool.id
      APPLICATION_CLIENT_ID = aws_cognito_user_pool_client.user_pool_client.id
      ADMIN_GROUP_NAME = var.user_pool_admin_group_name
    }
  }
}

output "userfunctions_lambda_auth" {
  value = aws_lambda_function.userfunctions_lambda_auth.function_name
}

