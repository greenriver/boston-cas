###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class MitigationReasons

    def run!
      [
        'Failed background check',
        'Failed credit check',
      ].each do |s|
        MitigationReason.where(name: s).first_or_create(name: s)
      end
    end

  end
end
