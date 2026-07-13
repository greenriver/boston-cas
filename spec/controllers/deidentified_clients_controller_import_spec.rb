###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeidentifiedClientsController, type: :controller do
  let!(:own_agency) { create(:agency, name: 'Own Agency') }
  let!(:other_agency) { create(:agency, name: 'Other Agency') }
  let!(:role) { create(:role, can_enter_deidentified_clients: true) }
  let!(:user) do
    u = create(:user, agency: own_agency)
    u.roles << role
    u
  end

  let(:xlsx_upload) do
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/fixtures/deidentified_client_xlsxs/initial.xlsx'),
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    )
  end

  before do
    authenticate user
    # Restrict an own-agency enterer to their own agency (mirrors editable_by).
    allow(DeidentifiedClient).to receive(:pathways_enabled?).and_return(false)
  end

  describe 'POST #import' do
    it 'rejects an agency outside the agencies available to the user' do
      expect do
        post :import, params: {
          deidentified_clients_xlsx: {
            file: xlsx_upload,
            agency_id: other_agency.id,
            update_availability: 'true',
          },
        }
      end.not_to change(DeidentifiedClient, :count)

      expect(flash[:alert]).to eq('You must select a valid agency')
      expect(response).to render_template(:choose_upload)
    end

    it 'rejects a submission that omits the availability choice' do
      post :import, params: {
        deidentified_clients_xlsx: {
          file: xlsx_upload,
          agency_id: own_agency.id,
        },
      }

      expect(flash[:alert]).to eq('You must choose whether to update client availability')
      expect(response).to render_template(:choose_upload)
    end

    it 'rejects a submission with no file attached' do
      post :import, params: {
        deidentified_clients_xlsx: {
          agency_id: own_agency.id,
          update_availability: 'true',
        },
      }

      expect(flash[:alert]).to eq('You must attach a file in the form.')
      expect(response).to render_template(:choose_upload)
    end
  end
end
