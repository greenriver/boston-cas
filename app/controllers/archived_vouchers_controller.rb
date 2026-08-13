###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ArchivedVouchersController < VouchersController
  def index
    @show_search = true
    @vouchers = @subprogram.vouchers.order(:id)
    @vouchers_for_page = @vouchers.archived
    @voucher_state = 'archived'
  end

  def restore
    @voucher.update(archived_at: nil, available: false, date_available: nil)
    flash[:notice] = 'Voucher restored'
    redirect_to action: :index
  end
end
