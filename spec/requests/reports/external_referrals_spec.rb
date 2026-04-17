###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports::ExternalReferrals', type: :request do
  let!(:user) { create(:user) }
  let!(:client) do
    create(
      :client,
      assessment_name: 'DeidentifiedClientAssessment',
      rrh_assessment_collected_at: 1.month.ago,
    )
  end

  let(:filter_params) do
    {
      filter: {
        assessment_types: ['DeidentifiedClientAssessment'],
        start: 6.months.ago.to_date.to_s,
        end: Date.current.to_s,
      },
    }
  end

  describe 'authentication' do
    it 'redirects unauthenticated users' do
      get reports_external_referrals_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'GET /reports/external_referrals' do
    before { sign_in user }

    it 'returns a successful response' do
      get reports_external_referrals_path, params: filter_params
      expect(response).to have_http_status(:ok)
    end

    # Specifically requested to avoid sending test clients externally
    it 'excludes clients with last_name Test or Fake' do
      create(:client, last_name: 'Test', assessment_name: 'DeidentifiedClientAssessment', rrh_assessment_collected_at: 1.month.ago)
      create(:client, last_name: 'Fake', assessment_name: 'DeidentifiedClientAssessment', rrh_assessment_collected_at: 1.month.ago)

      get reports_external_referrals_path, params: filter_params
      expect(response.body).to include(client.full_name)
      expect(response.body).not_to match(/\b(Test|Fake)\b.*Last|Last.*(Test|Fake)/)
    end

    it 'returns no clients when assessment_types is blank' do
      params = { filter: { assessment_types: [''], start: 6.months.ago.to_date.to_s, end: Date.current.to_s } }
      get reports_external_referrals_path, params: params
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No assessments completed in the chosen range')
    end

    it 'excludes clients outside the date range' do
      out_of_range = create(:client, first_name: 'OutOfRange', assessment_name: 'DeidentifiedClientAssessment', rrh_assessment_collected_at: 2.years.ago)
      params = { filter: { assessment_types: ['DeidentifiedClientAssessment'], start: 6.months.ago.to_date.to_s, end: Date.current.to_s } }

      get reports_external_referrals_path, params: params
      expect(response.body).to include(client.full_name)
      expect(response.body).not_to include(out_of_range.full_name)
    end
  end

  describe 'POST /reports/external_referrals/refer' do
    before { sign_in user }
    context 'when referrals[clients] params are missing (regression: malformed field name)' do
      it 'does not raise NoMethodError and returns a successful response' do
        expect do
          post refer_reports_external_referrals_path(format: :xlsx), params: filter_params
        end.not_to raise_error

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when clients are selected' do
      it 'creates ExternalReferral records for checked clients' do
        params = filter_params.merge(referrals: { clients: { client.id.to_s => '1' } })

        expect do
          post refer_reports_external_referrals_path(format: :xlsx), params: params
        end.to change(ExternalReferral, :count).by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no clients are checked (all values are 0)' do
      it 'does not create ExternalReferral records' do
        params = filter_params.merge(referrals: { clients: { client.id.to_s => '0' } })

        expect do
          post refer_reports_external_referrals_path(format: :xlsx), params: params
        end.not_to change(ExternalReferral, :count)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
