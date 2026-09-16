###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsMailer, type: :mailer do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:match) { create :client_opportunity_match, match_route: route }
  let(:contact) { create :contact }

  it 'renders the Eligibility Screening HSP email' do
    match.hsp_contacts << contact
    match.fourteen_eligibility_screening_decision.initialize_decision!(send_notifications: false)
    notification = Notifications::Fourteen::FourteenEligibilityScreeningHsp.create!(match: match, recipient: contact)
    mail = described_class.fourteen_eligibility_screening_hsp(notification)
    expect(mail.to).to eq([contact.email])
    expect(mail.body.encoded).to include('Eligibility Screening')
  end
end
