###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class InProgressVouchersController < VouchersController
  def index
    @show_search = true
    @vouchers = @subprogram.vouchers.order(:id)
    @search = search_setup(scope: :client_search)
    @vouchers_for_page = @search.select { |v| v.status_match.present? && v.status_match.active && !v.archived? }
    if @search_string.present?
      @vouchers_for_page = @vouchers_for_page.select { |v| v.status_match.present? && !v.status_match.confidential? }
      @voucher_state = 'matching in-progress'
    else
      @voucher_state = 'in-progress'
    end
  end
end
