###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class AdministrativeCancel < Base
    def self.available(include_other: true, route: nil) # rubocop:disable Lint/UnusedMethodArgument
      other = MatchDecisionReasons::Other.first
      # none = OpenStruct.new(name: 'None', id: nil)
      av = active.to_a
      # av << none
      if route.present?
        av.reject! { |reason| route.removed_admin_reasons.include?(reason.name) } if route.removed_admin_reasons.any?
        av += limited.where(name: route.additional_admin_reasons).to_a if route.additional_admin_reasons.any?
      end
      av << other

      av
    end

    def self.available_for_provider_only(include_other: true, route: nil) # rubocop:disable Lint/UnusedMethodArgument
      other = MatchDecisionReasons::Other.first
      # none = OpenStruct.new(name: 'None', id: nil)
      av = active.where(name: provider_only_options).to_a
      av << other if include_other

      av
    end

    def self.provider_only_options
      [
        'Vacancy should not have been entered',
        'Vacancy filled by other client',
      ]
    end

    def title
      _('Administrative Cancelation')
    end
  end
end
