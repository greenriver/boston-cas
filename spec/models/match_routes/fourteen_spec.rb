###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchRoutes::Fourteen, type: :model do
  describe '.match_steps' do
    it 'lists the seven forward steps in order' do
      expect(described_class.match_steps).to eq(
        'MatchDecisions::Fourteen::FourteenInitiateMatch' => 1,
        'MatchDecisions::Fourteen::FourteenMatchAcknowledgement' => 2,
        'MatchDecisions::Fourteen::FourteenClientReview' => 3,
        'MatchDecisions::Fourteen::FourteenEligibilityScreening' => 4,
        'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening' => 5,
        'MatchDecisions::Fourteen::FourteenOfferUnit' => 6,
        'MatchDecisions::Fourteen::FourteenConfirmMatchSuccess' => 7,
      )
    end
  end

  describe '.match_steps_for_reporting' do
    it 'places each decline step immediately after the step it reviews' do
      steps = described_class.match_steps_for_reporting
      ['MatchAcknowledgement', 'ClientReview', 'EligibilityScreening', 'SubsidyAdminScreening', 'OfferUnit'].each do |name|
        expect(steps["MatchDecisions::Fourteen::Fourteen#{name}Decline"]).to eq(steps["MatchDecisions::Fourteen::Fourteen#{name}"] + 1)
      end
    end

    it 'is strictly increasing and gap-free' do
      values = described_class.match_steps_for_reporting.values
      expect(values).to eq((1..values.size).to_a)
    end
  end

  it 'is registered in MatchRoutes::Base.all_routes' do
    expect(MatchRoutes::Base.all_routes).to include(described_class)
  end

  it 'reveals the client to the shelter agency from Acknowledge Match onward' do
    expect(described_class.new.first_client_step).to eq('MatchDecisions::Fourteen::FourteenMatchAcknowledgement')
  end

  describe '#client_reveal_step_for' do
    it 'reveals the client to HSP at Eligibility Screening and to HSA at Subsidy Administrator Screening' do
      route = described_class.new
      expect(route.client_reveal_step_for(:hsp_contacts)).to eq('MatchDecisions::Fourteen::FourteenEligibilityScreening')
      expect(route.client_reveal_step_for(:housing_subsidy_admin_contacts)).to eq('MatchDecisions::Fourteen::FourteenSubsidyAdminScreening')
    end

    it 'uses the default rules for every other contact type' do
      expect(described_class.new.client_reveal_step_for(:ssp_contacts)).to be_nil
    end
  end
end
