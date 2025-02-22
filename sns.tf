# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

resource "aws_sns_topic" "alarms_topic" {
  name = "AlarmsTopic"
}
