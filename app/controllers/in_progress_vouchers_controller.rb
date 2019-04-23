class InProgressVouchersController < VouchersController
  def index
    @vouchers = @subprogram.vouchers.preload(:status_match).order(:id)
    @vouchers_for_page = @vouchers.select{|v| v.status_match.present? && v.status_match.active}
    @voucher_state = "in-progress"
  end
end