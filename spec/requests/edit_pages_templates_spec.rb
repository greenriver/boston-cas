###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# This set of tests is a canary for when we add new variable rules.
# If a rule is added and doesn't add the associated templates, this test will fail.
RSpec.describe 'Edit pages render without missing variable-rule templates', type: :request do
  let!(:admin_user) { create :user }
  let!(:admin_role) { create :admin_role }

  before do
    admin_user.roles << admin_role
    sign_in admin_user
  end

  describe 'Admin edit user page' do
    let!(:other_user) { create :user } # id will be different from admin_user

    it 'responds successfully' do
      get "/admin/users/#{other_user.id}/edit"
      rule_classes = Rule.pluck(:type)
      # confirm we have at least some variable rules which require templates
      expect(rule_classes).to include('Rules::AgeGreaterThanX')
      expect(rule_classes).to include('Rules::AgeGreaterThanY')
      expect(response.status).to eq(200)
    end
  end

  describe 'Program details edit page' do
    let!(:route) { create :default_route }
    let!(:program) { create :program, match_route: route }
    let!(:sub_program) { create :sub_program, program: program }

    it 'responds successfully' do
      get "/programs/#{program.id}/sub_programs/#{sub_program.id}/program_details/edit"
      expect(response.status).to eq(200)
    end
  end
end
