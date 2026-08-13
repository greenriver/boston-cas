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
    expect(b.added).to eq(0)
    expect(b.skipped_identifiers).to contain_exactly(home_base_id)
    expect(DeidentifiedClient.where(client_identifier: home_base_id).count).to eq(1)
  end

  it 'reports a colliding ID once even when it appears on multiple rows' do
    DeidentifiedClientsXlsx.new(content: content).import(agency_a, update_availability: true)

    multi = DeidentifiedClientsXlsx.new(content: build_xlsx([row, row]))
    multi.import(agency_b, update_availability: true)

    expect(multi.skipped_identifiers).to eq([home_base_id])
  end

  it 'reports a row with bad data instead of silently dropping it, and still imports the good rows' do
    bad_row = ['1', 'MAYBE', 'HB-BAD', 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'No', 'No', 'No']
    importer = DeidentifiedClientsXlsx.new(content: build_xlsx([row, bad_row]))
    importer.import(agency_a, update_availability: true)

    expect(importer.added).to eq(1) # only the good row counted
    expect(DeidentifiedClient.find_by(agency: agency_a, client_identifier: home_base_id)).to be_present

    failed = importer.clients.detect { |c| c.client_identifier == 'HB-BAD' }
    expect(failed).to be_present
    expect(failed.errors).to be_present # surfaces in import.haml's problems table
    expect(DeidentifiedClient.find_by(client_identifier: 'HB-BAD')).to be_nil
  end

  it 'raises and rolls the whole import back on a non-user-correctable save failure' do
    existing = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'ALREADY-HERE',
      available: true,
      actively_homeless: true,
    )

    # Simulate a DB-level failure while persisting the assessment (validation is skipped for
    # these, so only a hard error can occur here).
    allow_any_instance_of(DeidentifiedClientAssessment).to receive(:save!).and_raise(ActiveRecord::StatementInvalid, 'boom')

    importer = DeidentifiedClientsXlsx.new(content: content)
    expect { importer.import(agency_a, update_availability: true) }.to raise_error(ActiveRecord::StatementInvalid)

    # The up-front availability reset must be rolled back, and the new roster client must not persist.
    expect(existing.reload.available).to eq(true)
    expect(DeidentifiedClient.find_by(client_identifier: home_base_id)).to be_nil
  end

  it 'reports an unexpected internal error to Sentry after the transaction commits' do
    importer = DeidentifiedClientsXlsx.new(content: content)
    # An unexpected failure in row processing that attaches no user-facing error.
    allow(importer).to receive(:clean_row).and_raise(RuntimeError, 'kaboom')

    expect(Sentry).to receive(:capture_exception).with(instance_of(RuntimeError))

    importer.import(agency_a, update_availability: true)
    # The row could not be processed, so nothing was imported, but the run still committed.
    expect(importer.added).to eq(0)
  end

  it 'does not report buffered internal errors to Sentry when the transaction rolls back' do
    # First row hits an unexpected error (would be buffered); second row forces a hard rollback.
    first_id = 'HB-FIRST'
    first_row = ['1', 'No', first_id, 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'No', 'No', 'No']
    importer = DeidentifiedClientsXlsx.new(content: build_xlsx([first_row, row]))

    allow(importer).to receive(:clean_row).and_wrap_original do |original, client, row_hash|
      raise 'kaboom' if row_hash[:client_identifier] == first_id

      original.call(client, row_hash)
    end
    allow_any_instance_of(DeidentifiedClientAssessment).to receive(:save!).and_raise(ActiveRecord::StatementInvalid, 'boom')

    # The buffered first-row error must NOT be flushed, because its transaction rolled back.
    expect(Sentry).not_to receive(:capture_exception)

    expect { importer.import(agency_a, update_availability: true) }.to raise_error(ActiveRecord::StatementInvalid)
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

  it 'keeps a client in the roster available even when their row fails to parse' do
    existing = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'HB-BADCELL',
      available: true,
      actively_homeless: true,
      veteran: false,
    )
    bad_row = ['1', 'No', 'HB-BADCELL', 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'MAYBE', 'No', 'No']

    importer = DeidentifiedClientsXlsx.new(content: build_xlsx([row, bad_row]))
    importer.import(agency_a, update_availability: true)

    expect(existing.reload.available).to eq(true)
    # The row is a full no-op, not just availability-preserving: the unparseable Veteran cell
    # must not have been applied.
    expect(existing.veteran).to eq(false)
    failed = importer.clients.detect { |c| c.client_identifier == 'HB-BADCELL' }
    expect(failed.errors).to be_present
    expect(importer.touched).to eq(0)
  end

  it 'keeps a client available when their row is valid but the save fails' do
    existing = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: home_base_id,
      available: true,
      actively_homeless: true,
    )
    # The row must parse completely clean for this to exercise the no-validation-errors branch:
    # an unknown shelter location attaches an error without raising, which would look like bad
    # user data instead.
    Neighborhood.create!(name: 'Fort Worth')
    allow_any_instance_of(DeidentifiedClient).to receive(:update).and_return(false)

    # A false return with no validation errors is an internal failure, not bad user data, so it
    # must be reported rather than silently skipped.
    expect(Sentry).to receive(:capture_message).with("De-identified roster save halted for client #{home_base_id}")

    DeidentifiedClientsXlsx.new(content: content).import(agency_a, update_availability: true)

    expect(existing.reload.available).to eq(true)
  end

  it 'does not activate a previously unavailable client when their row fails to parse' do
    # Activating a client off a row we couldn't parse would return them to matching with the stale
    # attributes already on record.
    existing = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'HB-BADCELL',
      available: false,
      actively_homeless: true,
    )
    bad_row = ['1', 'No', 'HB-BADCELL', 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'MAYBE', 'No', 'No']

    DeidentifiedClientsXlsx.new(content: build_xlsx([row, bad_row])).import(agency_a, update_availability: true)

    expect(existing.reload.available).to eq(false)
  end

  it 'still de-lists a client absent from the roster when another row fails to parse' do
    dropped = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'NOT-IN-FILE',
      available: true,
      actively_homeless: true,
    )
    create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'HB-BADCELL',
      available: true,
      actively_homeless: true,
    )
    bad_row = ['1', 'No', 'HB-BADCELL', 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'MAYBE', 'No', 'No']

    DeidentifiedClientsXlsx.new(content: build_xlsx([row, bad_row])).import(agency_a, update_availability: true)

    expect(dropped.reload.available).to eq(false)
  end

  it 'lets the parseable row win when a client appears on both a good and a bad row' do
    # A hand-maintained roster can list the same Home-base ID twice. The successful row must be
    # applied regardless of which side of it the failing row falls on, and the end-of-loop
    # availability restore must not undo it.
    dup_a = create(:deidentified_client, agency: agency_a, client_identifier: 'HB-DUP-A', available: false, veteran: true)
    dup_b = create(:deidentified_client, agency: agency_a, client_identifier: 'HB-DUP-B', available: false, veteran: true)
    good = ->(id) { ['1', 'No', id, 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'No', 'No', 'No'] }
    bad = ->(id) { ['1', 'No', id, 'No', 'No', '3', '240', 'Yes', 'No', 'No', 'Yes', 'No', 'MAYBE', 'No', 'No'] }

    importer = DeidentifiedClientsXlsx.new(
      content: build_xlsx([good.call('HB-DUP-A'), bad.call('HB-DUP-A'), bad.call('HB-DUP-B'), good.call('HB-DUP-B')]),
    )
    importer.import(agency_a, update_availability: true)

    # good-then-bad
    expect(dup_a.reload.available).to eq(true)
    expect(dup_a.veteran).to eq(false)
    # bad-then-good
    expect(dup_b.reload.available).to eq(true)
    expect(dup_b.veteran).to eq(false)
  end

  it 'leaves existing availability untouched when update_availability is not set' do
    # A client already available but absent from the uploaded roster. With update_availability
    # off there is no up-front reset, so this client must stay available rather than be de-listed.
    dropped = create(
      :deidentified_client,
      agency: agency_a,
      client_identifier: 'NOT-IN-FILE',
      available: true,
      actively_homeless: true,
    )

    DeidentifiedClientsXlsx.new(content: content).import(agency_a, update_availability: false)

    expect(dropped.reload.available).to eq(true)
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
