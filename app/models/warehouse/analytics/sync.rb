###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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
  end
end
