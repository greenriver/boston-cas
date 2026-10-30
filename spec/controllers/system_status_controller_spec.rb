###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SystemStatusController, type: :controller do
  describe '#details' do
    it 'includes the release alongside revision/branch in the JSON payload' do
      allow(Git).to receive(:release).and_return('v1.2.3+4')

      get :details

      payload = JSON.parse(response.body)
      expect(payload['release']).to eq('v1.2.3+4')
    end

    it 'omits/nils the release rather than erroring when none is available' do
      allow(Git).to receive(:release).and_return(nil)

      get :details

      payload = JSON.parse(response.body)
      expect(payload['release']).to be_nil
      expect(response.status).not_to eq(500)
    end
  end
end
