###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class MatchDecisionStep < ApplicationRecord
  belongs_to :route, class_name: 'MatchRoutes::Base'

  validates :decision_type, presence: true, uniqueness: { scope: :route_id }
end
