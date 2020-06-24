###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class InProgressVouchersController < VouchersController
  def index
    @vouchers = @subprogram.vouchers.order(:id)
    @q = @vouchers.preload(:client_opportunity_matches).ransack(params[:q])
    @vouchers_for_page = @q.result.select{|v| v.status_match.present? && v.status_match.active}
    if params[:q]&.[](:client_search).present?
      @vouchers_for_page = @vouchers_for_page.select{|v| v.status_match.present? && !v.status_match.confidential?}
      @voucher_state = "matching in-progress"
    else
      @voucher_state = "in-progress"
    end
  end
end