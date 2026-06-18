###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::Sync
  include ArelHelper

  def self.run!
    Warehouse::Analytics::Client.sync!
    Warehouse::Analytics::OpportunityCategory.sync!
    Warehouse::Analytics::Opportunity.sync!
    Warehouse::Analytics::Referral.sync!
    Warehouse::Analytics::Step.sync!
    Warehouse::Analytics::ReferralContact.sync!
    Warehouse::Analytics::CasUser.sync!
    Warehouse::Analytics::ReferralUser.sync!
    Warehouse::Analytics::RejectionReason.sync!
  end
end
