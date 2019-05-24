class SuccessfulVouchersController < VouchersController
  def index
    @vouchers = @subprogram.vouchers.preload(:status_match).order(:id)
    @q = @vouchers.ransack(params[:q])
    @vouchers_for_page = @q.result.preload(:status_match).select{|v| v.status_match.present? && v.status_match.successful?}
    @voucher_state = "successful"
  end
end