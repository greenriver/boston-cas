###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::Sync
  include ArelHelper

  def self.run!
    Warehouse::Analytics::Client.sync!
    Warehouse::Analytics::OpportunityCategory.sync!
    Warehouse::Analytics::Opportunity.sync!
    Warehouse::Analytics::Workflow.sync!
    Warehouse::Analytics::Step.sync!
    Warehouse::Analytics::WorkflowContact.sync!
    Warehouse::Analytics::CasUser.sync!
    Warehouse::Analytics::WorkflowUser.sync!
  end
end
