###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ImportedClientAssessment < NonHmisAssessment
  validates :set_asides_housing_status, presence: true
  validates :days_homeless_in_the_last_three_years, presence: true, numericality: { less_than_or_equal_to: 1096 }
  validates :shelter_name, presence: true
  validates :entry_date, presence: true
  validates :phone_number, presence: true
  # validates :income_total_monthly, presence: true, numericality: true
  validates :voucher_agency, presence: true, if: :have_tenant_voucher?
end