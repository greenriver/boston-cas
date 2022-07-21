require 'aws-sdk-iam'
require 'aws-sdk-elasticloadbalancingv2'
require 'aws-sdk-ecr'
require 'aws-sdk-ecs'
require 'aws-sdk-secretsmanager'
require 'aws-sdk-autoscaling'
require 'aws-sdk-ec2'
require 'aws-sdk-cloudwatchevents'
require 'aws-sdk-cloudwatch'
require 'aws-sdk-cloudwatchlogs'
require 'aws-sdk-ssm'
require 'aws-sdk-s3'
require 'active_support'

module AwsSdkHelpers
  extend ActiveSupport::Concern

  DEFAULT_AWS_REGION = 'us-east-1'.freeze

  module ClientMethods
    define_singleton_method(:iam) { Aws::IAM::Client.new }
    define_singleton_method(:elbv2) { Aws::ElasticLoadBalancingV2::Client.new }
    define_singleton_method(:ecr) { Aws::ECR::Client.new }
    define_singleton_method(:ecs) { Aws::ECS::Client.new }
    define_singleton_method(:secretsmanager) { Aws::SecretsManager::Client.new }
    define_singleton_method(:autoscaling) { Aws::AutoScaling::Client.new }
    define_singleton_method(:ec2) { Aws::EC2::Client.new }
    define_singleton_method(:cloudwatchevents) { Aws::CloudWatchEvents::Client.new }
    define_singleton_method(:cw) { Aws::CloudWatch::Client.new }
    define_singleton_method(:cwl) { Aws::CloudWatchLogs::Client.new }
    define_singleton_method(:ssm) { Aws::SSM::Client.new }
    define_singleton_method(:s3) { Aws::S3::Client.new(region: ENV.fetch('AWS_REGION', DEFAULT_AWS_REGION)) }

    define_method(:iam)              { AwsSdkHelpers::ClientMethods.iam }
    define_method(:elbv2)            { AwsSdkHelpers::ClientMethods.elbv2 }
    define_method(:ecr)              { AwsSdkHelpers::ClientMethods.ecr }
    define_method(:ecs)              { AwsSdkHelpers::ClientMethods.ecs }
    define_method(:secretsmanager)   { AwsSdkHelpers::ClientMethods.secretsmanager }
    define_method(:autoscaling)      { AwsSdkHelpers::ClientMethods.autoscaling }
    define_method(:ec2)              { AwsSdkHelpers::ClientMethods.ec2 }
    define_method(:cloudwatchevents) { AwsSdkHelpers::ClientMethods.cloudwatchevents }
    define_method(:cw)               { AwsSdkHelpers::ClientMethods.cw }
    define_method(:cwl)              { AwsSdkHelpers::ClientMethods.cwl }
    define_method(:ssm)              { AwsSdkHelpers::ClientMethods.ssm }
    define_method(:s3)               { AwsSdkHelpers::ClientMethods.s3 }
  end

  module Helpers
    include AwsSdkHelpers::ClientMethods

    def self.cluster_name
      ENV.fetch('CLUSTER_NAME', 'openpath')
    end

    def _cluster_name
      AwsSdkHelpers::Helpers.cluster_name
    end

    def self.capacity_providers(cluster)
      r = {}
      capacity_provider_names = AwsSdkHelpers::ClientMethods.ecs.describe_clusters(clusters: [cluster]).clusters.first.capacity_providers
      AwsSdkHelpers::ClientMethods.ecs.describe_capacity_providers(capacity_providers: capacity_provider_names).capacity_providers.each do |capacity_provider|
        asg_name = capacity_provider.auto_scaling_group_provider.auto_scaling_group_arn.split('/').last
        asg = AwsSdkHelpers::ClientMethods.autoscaling.describe_auto_scaling_groups(auto_scaling_group_names: [asg_name]).auto_scaling_groups.first

        launch_template_id = asg.mixed_instances_policy.launch_template.launch_template_specification.launch_template_id
        launch_template_versions = AwsSdkHelpers::ClientMethods.ec2.describe_launch_template_versions(launch_template_id: launch_template_id)

        ami_id = launch_template_versions.launch_template_versions[0].launch_template_data.image_id

        r[capacity_provider.name] = {
          name: capacity_provider.name,
          ami_id: ami_id,
        }
      end
      return r
    end

    def _capacity_providers(cluster = nil)
      cluster ||= _cluster_name
      @capacity_providers ||= AwsSdkHelpers::Helpers.capacity_providers(cluster)
    end

    def self.get_capacity_provider_name(which = 'Spot', target_group_name = '')
      default_path = "/OpenPath/CapacityProviders/#{which}"
      override_path = "/#{target_group_name}/CapacityProviders/#{which}"

      params = AwsSdkHelpers::ClientMethods.ssm.get_parameters(
        {
          names: [
            default_path,
            override_path,
          ],
          with_decryption: true,
        },
      )

      if params.parameters.count == 2
        params.parameters.find { |p| p[:name] == override_path }[:value]
      elsif params.parameters.count == 1
        params.parameters[0][:value]
      else
        Rails.logger.warn "No capacity provider name found: #{which}" if defined?(Rails)
        puts "❗ No capacity provider name found: #{which}"
      end

      params.parameters.any? ? params.parameters[0][:value] : ''
    end

    def _spot_capacity_provider_name(target_group_name = false)
      target_group_name ||= self.respond_to?(:target_group_name) ? self.target_group_name : ENV.fetch('TARGET_GROUP_NAME', '') # rubocop:disable Style/RedundantSelf
      @_spot_capacity_provider_name ||= AwsSdkHelpers::Helpers.get_capacity_provider_name('Spot', target_group_name)
    end

    def _on_demand_capacity_provider_name(target_group_name = false)
      target_group_name ||= self.respond_to?(:target_group_name) ? self.target_group_name : ENV.fetch('TARGET_GROUP_NAME', '') # rubocop:disable Style/RedundantSelf
      @_on_demand_capacity_provider_name ||= AwsSdkHelpers::Helpers.get_capacity_provider_name('OnDemand', target_group_name)
    end

    def self.get_secret(secret_arn)
      resp = AwsSdkHelpers::ClientMethods.secretsmanager.get_secret_value(
        secret_id: secret_arn,
      )

      return resp.to_h[:secret_string]
    rescue Aws::Errors::MissingCredentialsError
      warn 'Need credentials to sync secrets (or run on a server/container with a role)'
      puts 'ERROR=secretsyncfailed'
    end
  end
end
