module Cas
  class UpdateVoucherAvailability

    def run!
      vouchers = Voucher.where.not(date_available: nil).where(available: false)
      vouchers.each do |v|
        if v.opportunity.blank? && v.date_available <= Date.today
          v.update! available: true, date_available: nil
        end
      end
    end

    private
    
  end
end
