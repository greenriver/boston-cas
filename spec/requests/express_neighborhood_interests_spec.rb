require 'rails_helper'

RSpec.describe "Expressing neighborhood interests", type: :request do
  let!(:role) { create :admin_role }
  let!(:user) { create :user }

  let!(:cambridge) { create :neighborhood_cambridge }
  let!(:beacon_hill) { create :neighborhood_beacon_hill }

  let(:client) { NonHmisClient.first }

  context "by an administrator" do
    before :each do
      user.roles << role
      sign_in user
    end

    it "stores multiple values" do
      post deidentified_clients_path, params: { deidentified_client: { client_assessments_attributes: [ neighborhood_interests: [ "#{cambridge.id}", "#{beacon_hill.id}" ] ] } }

      expect(response).to redirect_to deidentified_clients_url

      expect(client.current_assessment.neighborhood_interests).to include cambridge.id
      expect(client.current_assessment.neighborhood_interests).to include beacon_hill.id
    end

    it "converts strings to ints" do
      post deidentified_clients_path, params: { deidentified_client: { client_assessments_attributes: [ neighborhood_interests: [ "#{cambridge.id}" ] ] } }

      expect(response).to redirect_to deidentified_clients_url

      expect(client.current_assessment.neighborhood_interests).to_not include "#{cambridge.id}"
      expect(client.current_assessment.neighborhood_interests).to include cambridge.id
    end
  end
end