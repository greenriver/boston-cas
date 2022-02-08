###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class MitigationReasons
    def run!
      [
        'Failed background check',
        'Failed credit check',
        'Failed criminal history check',
        'Housing history or evictions',
        'Landlord Reference(s)',
        'Ineligible Income Status',
        'Sexual Offender History',
        'Other',
      ].each do |s|
        MitigationReason.where(name: s).first_or_create(name: s)
      end
    end
  end
end
