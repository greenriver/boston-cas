module Cas
  class UpdateVoucherAvailability
    def run!
      vouchers = Voucher.where.not(date_available: nil).where(available: false)
      vouchers.each do |v|
        next unless v.opportunity.blank? && v.date_available <= Date.today

        begin
          v.update! available: true, date_available: nil
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Error for voucher: #{v.id} #{e.message}"
        end
      end
    end
  end
end
