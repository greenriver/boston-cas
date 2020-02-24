###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchDecisionReasons
  class AdministrativeCancel < Base

    def self.available(include_other: true)
      begin
        other = MatchDecisionReasons::Other.first
        # none = OpenStruct.new(name: 'None', id: nil)
        av = active.to_a
        av << other
        # av << none
        av
      end
    end

    def self.available_for_provider_only(include_other: true)
      begin
        other = MatchDecisionReasons::Other.first
        # none = OpenStruct.new(name: 'None', id: nil)
        av = active.where(name: provider_only_options).to_a
        av << other if include_other
        av
      end
    end

    def self.provider_only_options
      [
        'Vacancy should not have been entered',
        'Vacancy filled by other client',
      ]
    end
  end
end