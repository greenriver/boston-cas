###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

#
# Current
#
# Request-scoped attributes backed by ActiveSupport::CurrentAttributes.
#
# Persistence scope:
# - Per request/thread (and fiber): values are isolated to the current execution
#   context and cleared between requests by Rails.
# - Not persisted to the database or session; not shared across processes.
# - In background jobs or non-request contexts, set and clear manually.
#
# Example (controller):
#   around_action :with_skip_build_assessment_if_missing, only: :index
#   private def with_skip_build_assessment_if_missing
#     Current.skip_build_assessment_if_missing = true
#     yield
#   ensure
#     Current.skip_build_assessment_if_missing = nil
#   end
#
# Example (model):
#   return if Current.skip_build_assessment_if_missing
#
# Use for request-local flags to avoid global side effects from class-level state.
#

class Current < ActiveSupport::CurrentAttributes
  attribute :skip_build_assessment_if_missing
end
