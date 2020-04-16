###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Cas
  class UpdateVoucherAvailability

    def run!
      vouchers = Voucher.where.not(date_available: nil).where(available: false)
      vouchers.each do |v|
        if v.opportunity&.status_match.blank? && v.date_available <= Date.current
          begin
            v.update! available: true, date_available: nil
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Error for voucher: #{v.id} #{e.message}"
          end
        end
      end
    end

    private

  end
end
