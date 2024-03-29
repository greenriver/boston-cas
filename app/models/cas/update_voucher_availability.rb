###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Cas
  class UpdateVoucherAvailability

    def run!
      vouchers = Voucher.where.not(date_available: nil).where(available: false)
      vouchers.find_each do |v|
        if v.opportunity&.status_match.blank? && v.date_available <= Date.current
          begin
            v.update!(available: true, date_available: nil)
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Error for voucher: #{v.id} #{e.message}"
          end
        end
      end
      # Find any vouchers that had been marked available in the future, but for whatever reason are
      # connected to an opportunity that isn't availablea and has no active or successful match.
      vouchers = Voucher.where.not(date_available: nil).where(available: true).
        joins(:opportunity).
        merge(Opportunity.where(available_candidate: false))
      vouchers.find_each do |v|
        next if v.opportunity&.status_match.present? || v.date_available >= Date.current

        begin
          v.update!(available: true, date_available: nil)
          v.opportunity.update(available: true, available_candidate: true)
          # puts "Updating v: #{v.id}"
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Error for voucher: #{v.id} #{e.message}"
        end
      end

      # Find any vouchers that had been marked available, but for whatever reason are
      # connected to an opportunity that isn't availablea and has no active or successful match.
      vouchers = Voucher.where(date_available: nil, available: true).
        joins(:opportunity).
        merge(Opportunity.where(available_candidate: false))
      vouchers.find_each do |v|
        next if v.opportunity&.status_match.present?

        begin
          v.update!(available: true)
          v.opportunity.update(available: true, available_candidate: true)
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Error for voucher: #{v.id} #{e.message}"
        end
      end
    end

    private

  end
end
