###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class Opportunities

    def run!
      ApplicationRecord.cache do
        # flag some vouchers as available
        voucher_ids = Voucher.pluck(:id).shuffle[0..5]
        vouchers = Voucher.where(id: voucher_ids)
        vouchers.each do |v|
          v.update(available: true)
          op = Opportunity.create!(voucher: v, available: true)
        end
      end
    end

  end
end
