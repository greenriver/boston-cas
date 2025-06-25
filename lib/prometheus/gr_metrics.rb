# __DEVOPS__

# frozen_string_literal: true

module Prometheus
  module GrMetrics
    DIRECTORY = ENV.fetch('METRICS_DIR', '/tmp/metrics')
  end
end
