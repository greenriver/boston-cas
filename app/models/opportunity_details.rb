###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module OpportunityDetails
  # the classes in this module encapsulate the details for a given opportunity
  # which may be fetched via multiple strategies depending on the opportunity's
  # associations

  # factory method
  def self.build opportunity
    if opportunity.voucher.present?
      ViaVoucher.new opportunity
    elsif opportunity.unit.present?
      ViaUnit.new opportunity
    else
      # Blank.new opportunity
    end
  end

end
