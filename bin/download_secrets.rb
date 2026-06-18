#!/usr/bin/env ruby
###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

require_relative '../config/deploy/docker/lib/aws_sdk_helpers'

puts AwsSdkHelpers::Helpers.get_secret(ENV.fetch('SECRET_ARN'))
