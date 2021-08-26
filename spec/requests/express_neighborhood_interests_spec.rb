require 'rails_helper'

RSpec.describe "Expressing neighborhood interests", type: :request do
  let!(:role) { create :admin_role }
  let!(:user) { create :user }

  let!(:cambridge) { create :neighborhood_cambridge }
  let!(:beacon_hill) { create :neighborhood_beacon_hill }

  let(:client) { create :deidentified_client }

  context 'by an administrator' do
    before :each do
      user.roles << role
      sign_in user
    end

    it 'stores multiple values' do
      post deidentified_client_non_hmis_assessments_path(deidentified_client_id: client.id, params: { deidentified_client_assessment: { neighborhood_interests: [cambridge.id.to_s, beacon_hill.id.to_s] }})
      expect(response).to redirect_to deidentified_client_url(client)

      expect(client.current_assessment.neighborhood_interests).to include cambridge.id
      expect(client.current_assessment.neighborhood_interests).to include beacon_hill.id
    end

    it 'converts strings to ints' do
      post deidentified_client_non_hmis_assessments_path(deidentified_client_id: client.id, params: { deidentified_client_assessment: { neighborhood_interests: [ cambridge.id.to_s ] }})
      expect(response).to redirect_to deidentified_client_url(client)

      expect(client.current_assessment.neighborhood_interests).to_not include cambridge.id.to_s
      expect(client.current_assessment.neighborhood_interests).to include cambridge.id
    end
  end
end
