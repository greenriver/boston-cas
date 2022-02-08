###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SuccessfulVouchersController < VouchersController
  def index
    @vouchers = @subprogram.vouchers.order(:id)
    @q = @vouchers.ransack(params[:q])
    @vouchers_for_page = @q.result.select{|v| v.status_match.present? && v.status_match.successful?}
    if params[:q]&.[](:client_search).present?
      @vouchers_for_page = @vouchers_for_page.select{|v| v.status_match.present? && !v.status_match.confidential?}
      @voucher_state = "matching successful"
    else
      @voucher_state = "successful"
    end
  end
end
