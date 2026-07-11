###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeidentifiedClientsXlsx, type: :model do
  let(:agency_a) { create :agency }
  let(:agency_b) { create :agency }
  let(:home_base_id) { 'HB-0427X' }
  # order per file_attributes: shelter_location, disabling_condition, client_identifier,
  # substance_abuse, mental_health, occurrences, days_homeless, family_member, sixty_plus,
  # is_currently_youth, chronic_homeless, pregnancy, veteran, hiv_aids, health_prioritized
  let(:row) { ['1', 'No', home_base_id, 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'No', 'No', 'No'] }
  let(:content) { build_xlsx([row]) }

  it 'skips a Home-base ID already registered to another agency (no silent drop, no duplicate)' do
    a = DeidentifiedClientsXlsx.new(content: content)
    a.import(agency_a, update_availability: true)
    expect(a.added).to eq(1)
    expect(DeidentifiedClient.find_by(agency: agency_a, client_identifier: home_base_id)).to be_present

    b = DeidentifiedClientsXlsx.new(content: content)
    b.import(agency_b, update_availability: true)
    expect(b.skipped).to eq(1)
    expect(b.added).to eq(0)
    expect(b.skipped_identifiers).to include(home_base_id)
    expect(DeidentifiedClient.where(client_identifier: home_base_id).count).to eq(1)
  end

  it 'updates in place on a same-agency re-upload' do
    DeidentifiedClientsXlsx.new(content: content).import(agency_a, update_availability: true)
    again = DeidentifiedClientsXlsx.new(content: content)
    again.import(agency_a, update_availability: true)
    expect(again.touched).to eq(1)
    expect(again.skipped).to eq(0)
    expect(DeidentifiedClient.where(agency: agency_a, client_identifier: home_base_id).count).to eq(1)
  end

  def build_xlsx(rows)
    headers = DeidentifiedClientsXlsx.file_header
    pkg = Axlsx::Package.new
    pkg.workbook.add_worksheet do |sheet|
      sheet.add_row(headers)
      rows.each { |r| sheet.add_row(r, types: Array.new(r.length, :string)) }
    end
    pkg.to_stream.read
  end
end
