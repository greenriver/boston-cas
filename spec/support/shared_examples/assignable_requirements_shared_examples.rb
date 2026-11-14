###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# Includer defines:
#   send_request            - lambda taking an array of requirements_attributes; performs the request
#                             (including the changed_attributes) as the signed-in user
#   requirement_owner       - the record whose requirements are checked
#   changed_attributes      - non-requirement attribute changes the request makes, e.g. { name: 'New Name' }
#   minimal_role_attributes - permissions needed to reach the action, without can_assign_requirements
#
# creates_record: true skips the destroy example (nothing exists to destroy yet).
# other_attribute: false skips the other-attribute example for actions that permit nothing else.
RSpec.shared_examples 'assignable requirements' do |creates_record: false, other_attribute: true|
  let(:user) { create(:user) }
  let(:rule) { create(:bedroom_exact) }
  let(:new_requirement_params) do
    [{ 'rule_id' => rule.id.to_s, 'positive' => 'true', 'variable' => '2' }]
  end

  before do
    authenticate(user)
    user.roles = [role]
  end

  def expect_request_reached_action
    expect(response).not_to redirect_to(root_path)
    expect(flash[:alert]).to be_nil
  end

  context 'without can_assign_requirements' do
    let(:role) { create(:role, **minimal_role_attributes) }

    if other_attribute
      it 'saves the other attributes and creates no requirement' do
        send_request.call(new_requirement_params)

        expect_request_reached_action
        changed_attributes.each do |attribute, value|
          expect(requirement_owner.reload.public_send(attribute)).to eq(value)
        end
        expect(requirement_owner.requirements.count).to eq(0)
      end
    else
      it 'creates no requirement' do
        send_request.call(new_requirement_params)

        expect_request_reached_action
        expect(requirement_owner.requirements.count).to eq(0)
      end
    end

    unless creates_record
      it 'keeps an existing requirement when the request marks it for destruction' do
        existing = requirement_owner.requirements.create!(rule: rule, positive: true, variable: '2')

        send_request.call([{ 'id' => existing.id.to_s, '_destroy' => '1' }])

        expect_request_reached_action
        expect(requirement_owner.requirements.pluck(:id)).to eq([existing.id])
      end
    end
  end

  context 'with only can_assign_requirements added to the minimal role' do
    let(:role) { create(:role, **minimal_role_attributes, can_assign_requirements: true) }

    it 'saves the requirement with the posted rule and variable' do
      send_request.call(new_requirement_params)

      expect(requirement_owner.requirements.pluck(:rule_id, :positive, :variable)).to eq([[rule.id, true, '2']])
    end

    unless creates_record
      it 'destroys an existing requirement when the request marks it for destruction' do
        existing = requirement_owner.requirements.create!(rule: rule, positive: true, variable: '2')

        send_request.call([{ 'id' => existing.id.to_s, '_destroy' => '1' }])

        expect(Requirement.where(id: existing.id)).not_to exist
      end
    end
  end
end
