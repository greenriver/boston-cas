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
    expect(DeidentifiedClient.where(agency: agency_a, client_identifier: home_base_id).count).to eq(1)
  end

  it 'marks imported clients available and actively homeless when update_availability is set' do
    # Start from the ineligible state so the assertion fails if the importer stops
    # re-setting availability. update_availability first flips the whole agency to
    # available: false, then the matching row must flip it back to true.
    existing = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: home_base_id,
      available: false,
      actively_homeless: false,
    )

    importer = DeidentifiedClientsXlsx.new(content: content)
    importer.import(agency_a, update_availability: true)

    expect(importer.touched).to eq(1)
    existing.reload
    expect(existing.available).to eq(true)
    expect(existing.actively_homeless).to eq(true)
  end

  it 'marks previously-available clients absent from the new roster as unavailable' do
    dropped = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'NOT-IN-FILE',
      available: true,
      actively_homeless: true,
    )

    DeidentifiedClientsXlsx.new(content: content).import(agency_a, update_availability: true)

    # The uploaded roster only contains home_base_id, so the dropped client loses eligibility.
    expect(dropped.reload.available).to eq(false)
    expect(DeidentifiedClient.find_by(agency: agency_a, client_identifier: home_base_id)&.available).to eq(true)
  end

  it 'converts roster columns into the correct eligibility and special-population fields' do
    importer = DeidentifiedClientsXlsx.new(content: content)
    importer.import(agency_a, update_availability: true)
    expect(importer.added).to eq(1)

    client = DeidentifiedClient.find_by(agency: agency_a, client_identifier: home_base_id)
    # Each assertion below asserts a non-default value, so it fails if the mapping is
    # dropped or inverted. yes/no columns whose value ('No') equals the column default
    # are omitted: they re-exercise one branch and can't fail on a dropped assignment.
    expect(client.family_member).to eq(true)                 # 'Yes' -> true (yes-branch)
    expect(client.sixty_plus).to eq(false)                   # 'No'  -> false (no-branch; column default is nil)
    expect(client.calculated_chronic_homelessness).to eq(1)  # 'Yes' -> 1 (catches the ? 1 : 0 flip)
    expect(client.days_homeless).to eq(240)                  # numeric conversion
    expect(client.last_name).to eq("Anonymous - #{home_base_id}")
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
