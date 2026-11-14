###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VouchersController, type: :controller do
  # voucher_params is read only by #create (add_vouchers) and #bulk_update (vouchers_attributes),
  # so its requirements_attributes has no effect to observe; the voucher update action is the
  # call site that persists requirements.
  describe 'PATCH #update requirements' do
    let(:sub_program) { create(:sub_program) }
    let(:requirement_owner) { create(:voucher, sub_program: sub_program) }
    let(:changed_attributes) { {} }
    let(:minimal_role_attributes) { { can_view_vouchers: true, can_edit_vouchers: true, can_edit_voucher_rules: true } }
    let(:send_request) do
      ->(requirements) do
        patch :update, params: {
          program_id: sub_program.program_id,
          sub_program_id: sub_program.id,
          id: requirement_owner.id,
          voucher: { requirements_attributes: requirements },
        }
      end
    end

    it_behaves_like 'assignable requirements', other_attribute: false
  end
end
