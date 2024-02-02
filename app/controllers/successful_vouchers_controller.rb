###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SuccessfulVouchersController < VouchersController
  def index
    @show_search = true
    @vouchers = @subprogram.vouchers.order(:id)
    @search = search_setup(scope: :client_search)
    @vouchers_for_page = @search.select { |v| v.status_match.present? && v.status_match.successful? }
    if @search_string.present?
      @vouchers_for_page = @vouchers_for_page.select { |v| v.status_match.present? && !v.status_match.confidential? }
      @voucher_state = 'matching successful'
    else
      @voucher_state = 'successful'
    end
  end
end
