###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# __DEVOPS__

# frozen_string_literal: true

module Prometheus
  module GrMetrics
    DIRECTORY = ENV.fetch('METRICS_DIR', '/tmp/metrics')
  end
end
