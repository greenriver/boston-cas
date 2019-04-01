module CasSeeds
  class Opportunities
    def run!
      ActiveRecord::Base.cache do
        # flag some vouchers as available
        voucher_ids = Voucher.pluck(:id).sample(6)
        vouchers = Voucher.where(id: voucher_ids)
        vouchers.each do |v|
          v.update_attributes(available: true)
          op = Opportunity.create!(voucher: v, available: true)
        end
      end
    end
  end
end
