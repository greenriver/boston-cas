###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class HousingSubsidyAdminDecline < Base
    def self.available(include_other: false, route: nil)
      other = MatchDecisionReasons::Other.first
      # none = OpenStruct.new(name: 'None', id: nil)
      av = active.to_a
      # av << none
      if route.present?
        av.reject! { |reason| route.removed_hsa_reasons.include?(reason.name) } if route.removed_hsa_reasons.any?
        av += limited.where(name: route.additional_hsa_reasons).to_a if route.additional_hsa_reasons.any?
      end
      av << other if include_other

      av
    end

    def title
      "#{_('HSA')} Decline"
    end
  end
end
