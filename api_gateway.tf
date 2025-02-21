# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_api_gateway_rest_api" "rest_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "rest_api"
      version = "1.0"
    }
    components = {
      securitySchemes = {
        lambdaTokenAuthorizer = {
          type = "apiKey"
          name = "Authorization"
          in = "header"
          x-amazon-apigateway-authtype = "custom"
          x-amazon-apigateway-authorizer = {
            authorizerUri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.userfunctions_lambda_auth.function_name}/invocations"
            authorizerResultTtlInSeconds = 300
            type = "token"
          }
        }
      }
    }    
    paths = {
      "/users" = {
        get = {
          security = [ 
            {
              "lambdaTokenAuthorizer": []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            type                 = "aws_proxy"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.userfunctions_lambda.arn}/invocations"
          }
        },
        post = {
          security = [ 
            {
              "lambdaTokenAuthorizer": []
            }
          ]
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            type                 = "aws_proxy"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.userfunctions_lambda.arn}/invocations"
          }
        }
      },
      "/users/{userid}" = {
        security = [ 
          {
            "lambdaTokenAuthorizer": []
          }
        ]
        put = {
          security = [ 
            {
              "lambdaTokenAuthorizer": []
            }
          ]           
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            type                 = "aws_proxy"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.userfunctions_lambda.arn}/invocations"
          }
        },
        get = {
          security = [ 
            {
              "lambdaTokenAuthorizer": []
            }
          ]          
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            type                 = "aws_proxy"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.userfunctions_lambda.arn}/invocations"
          }
        },
        delete = {
          security = [ 
            {
              "lambdaTokenAuthorizer": []
            }
          ]          
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            type                 = "aws_proxy"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.userfunctions_lambda.arn}/invocations"
          }
        }
      }      
    }
  })

  name = "${var.workshop_stack_base_name}_rest_api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "rest_api" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_api" {
  deployment_id = aws_api_gateway_deployment.rest_api.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name = "Prod"
  xray_tracing_enabled = true
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.userfunctions_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_lambda_auth" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.userfunctions_lambda_auth.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/authorizers/*"
}

output "APIEndpoint" {
  value = aws_api_gateway_stage.rest_api.invoke_url
}

