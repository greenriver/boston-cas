class SuccessfulVouchersController < VouchersController
  def index
    @vouchers = @subprogram.vouchers.preload(:status_match).order(:id)
    @vouchers_for_page = @vouchers.select{|v| v.status_match.present? && v.status_match.successful?}
    @voucher_state = "successful"
  end
end