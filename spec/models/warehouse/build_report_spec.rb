###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Warehouse::BuildReport, type: :model do
  let(:build_report) { described_class.new }

  # Helper to check if warehouse is available for testing
  # In CI, Warehouse::Base.enabled? will return false, so these tests will be skipped
  # Tests should pass locally if the warehouse db is available
  def warehouse_available?
    # Try to check if warehouse is enabled, but catch any errors (like missing tables)

    Warehouse::Base.enabled?
  rescue StandardError
    false
  end

  describe '#run!' do
    context 'when warehouse is enabled' do
      before do
        allow(Warehouse::Base).to receive(:enabled?).and_return(true)
      end

      it 'fills all report tables' do
        expect(build_report).to receive(:fill_cas_report_table!)
        expect(build_report).to receive(:fill_cas_non_hmis_client_history_table!)
        expect(build_report).to receive(:fill_cas_vacancy_table!)

        build_report.run!
      end
    end

    context 'when warehouse is disabled' do
      before do
        allow(Warehouse::Base).to receive(:enabled?).and_return(false)
      end

      it 'only fills cas report table' do
        expect(build_report).to receive(:fill_cas_report_table!)
        expect(build_report).not_to receive(:fill_cas_non_hmis_client_history_table!)
        expect(build_report).not_to receive(:fill_cas_vacancy_table!)

        build_report.run!
      end
    end
  end

  # These tests require warehouse to be enabled and warehouse tables to exist
  # In CI where warehouse is disabled, these will be skipped
  describe '#fill_cas_vacancy_table!' do
    let(:program) { create(:program, name: 'Test Program') }
    let(:sub_program) { create(:sub_program, program: program, program_type: 'Sponsor-Based') }
    let(:voucher) do
      create(
        :voucher,
        sub_program: sub_program,
        created_at: 1.week.ago,
        available: true,
        updated_at: 3.days.ago,
      )
    end

    before do
      # Skip if warehouse is not available (catches errors from table checks)

      skip 'Warehouse database not available' unless warehouse_available?
      allow(Warehouse::CasVacancy).to receive(:transaction).and_yield
      allow(Warehouse::CasVacancy).to receive(:delete_all)
      allow(Warehouse::CasVacancy).to receive(:import!)
    rescue ActiveRecord::StatementInvalid, PG::UndefinedTable
      skip 'Warehouse database not available'
    end

    it 'creates vacancy records from vouchers' do
      voucher

      build_report.fill_cas_vacancy_table!

      expect(Warehouse::CasVacancy).to have_received(:delete_all)
      expect(Warehouse::CasVacancy).to have_received(:import!)
    end

    it 'sets vacancy attributes correctly' do
      voucher
      vacancies = []
      allow(Warehouse::CasVacancy).to receive(:new).and_wrap_original do |method, *args|
        vacancy = method.call(*args)
        vacancies << vacancy
        vacancy
      end

      build_report.fill_cas_vacancy_table!

      vacancy = vacancies.first
      expect(vacancy.program_id).to eq(program.id)
      expect(vacancy.sub_program_id).to eq(sub_program.id)
      expect(vacancy.program_name).to eq('Test Program')
      expect(vacancy.sub_program_name).to eq(sub_program.name)
      expect(vacancy.program_type).to eq('Sponsor-Based')
      expect(vacancy.vacancy_created_at).to be_within(1.second).of(voucher.created_at)
      expect(vacancy.vacancy_made_available_at).to be_within(1.second).of(voucher.available_at)
    end

    it 'sets route_name from program match_route' do
      match_route = create(:default_route)
      program.update(match_route: match_route)
      voucher

      vacancies = []
      allow(Warehouse::CasVacancy).to receive(:new).and_wrap_original do |method, *args|
        vacancy = method.call(*args)
        vacancies << vacancy
        vacancy
      end

      build_report.fill_cas_vacancy_table!

      expect(vacancies.first.route_name).to eq(match_route.title)
    end

    it 'sets route_name to unknown when match_route is nil' do
      program_with_route = create(:program, match_route: create(:default_route))
      sub_program_without_route = create(:sub_program, program: program_with_route, program_type: 'Sponsor-Based')
      create(:voucher, sub_program: sub_program_without_route, available: true)
      program_with_route.update_column(:match_route_id, nil) # Skip validations since we're testing the nil case

      vacancies = []
      allow(Warehouse::CasVacancy).to receive(:new).and_wrap_original do |method, *args|
        vacancy = method.call(*args)
        vacancies << vacancy
        vacancy
      end

      build_report.fill_cas_vacancy_table!

      vacancy = vacancies.find { |v| v.sub_program_id == sub_program_without_route.id }
      expect(vacancy.route_name).to eq('unknown')
    end

    it 'deletes all existing vacancies before importing' do
      voucher

      build_report.fill_cas_vacancy_table!

      expect(Warehouse::CasVacancy).to have_received(:delete_all).ordered
      expect(Warehouse::CasVacancy).to have_received(:import!).ordered
    end
  end

  # These tests require warehouse to be enabled and warehouse tables to exist
  # In CI where warehouse is disabled, these will be skipped
  describe '#fill_cas_non_hmis_client_history_table!' do
    let(:client) { create(:deidentified_client, created_at: 1.month.ago, deleted_at: nil) }

    before do
      # Skip if warehouse is not available (catches errors from table checks)

      skip 'Warehouse database not available' unless warehouse_available?
      allow(Warehouse::CasNonHmisClientHistory).to receive(:transaction).and_yield
      allow(Warehouse::CasNonHmisClientHistory).to receive(:delete_all)
      allow(Warehouse::CasNonHmisClientHistory).to receive(:import!)
    rescue ActiveRecord::StatementInvalid, PG::UndefinedTable
      skip 'Warehouse database not available'
    end

    it 'creates history records for deidentified clients' do
      client

      build_report.fill_cas_non_hmis_client_history_table!

      expect(Warehouse::CasNonHmisClientHistory).to have_received(:delete_all)
      expect(Warehouse::CasNonHmisClientHistory).to have_received(:import!)
    end

    it 'sets available_on from client created_at' do
      client
      history_records = []
      allow(Warehouse::CasNonHmisClientHistory).to receive(:new).and_wrap_original do |method, *args|
        record = method.call(*args)
        history_records << record
        record
      end

      build_report.fill_cas_non_hmis_client_history_table!

      record = history_records.first
      expect(record.cas_client_id).to eq(client.id)
      expect(record.available_on.to_date).to eq(client.created_at.to_date)
    end

    it 'sets unavailable_on when client was deleted' do
      deleted_at = 1.week.ago
      client.update(deleted_at: deleted_at)
      history_records = []
      allow(Warehouse::CasNonHmisClientHistory).to receive(:new).and_wrap_original do |method, *args|
        record = method.call(*args)
        history_records << record
        record
      end

      build_report.fill_cas_non_hmis_client_history_table!

      record = history_records.first
      expect(record.unavailable_on.to_date).to eq(deleted_at.to_date)
    end

    it 'sets part_of_a_family from client' do
      client.update(family_member: true)
      history_records = []
      allow(Warehouse::CasNonHmisClientHistory).to receive(:new).and_wrap_original do |method, *args|
        record = method.call(*args)
        history_records << record
        record
      end

      build_report.fill_cas_non_hmis_client_history_table!

      expect(history_records.first.part_of_a_family).to be true
    end

    it 'deletes all existing history before importing' do
      client

      build_report.fill_cas_non_hmis_client_history_table!

      expect(Warehouse::CasNonHmisClientHistory).to have_received(:delete_all).ordered
      expect(Warehouse::CasNonHmisClientHistory).to have_received(:import!).ordered
    end
  end

  describe '#fill_cas_report_table!' do
    let(:data_source) { create(:data_source, name: 'Test Data Source') }
    let(:project_client) { create(:hmis_project_client, data_source: data_source, id_in_data_source: '123') }
    let(:client) { create(:client, project_client: project_client) }
    let(:program) { create(:program, name: 'Test Program') }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:voucher) { create(:voucher, sub_program: sub_program) }
    let(:opportunity) { create(:opportunity, voucher: voucher) }
    let(:match) { create(:client_opportunity_match, client: client, opportunity: opportunity, match_route: program.match_route) }

    before do
      allow(Reporting::Decisions).to receive(:transaction).and_yield
      allow(Reporting::Decisions).to receive(:delete_all)
      allow(Reporting::Decisions).to receive(:import!)
    end

    context 'when warehouse is enabled' do
      before do
        # Skip if warehouse is not available (catches errors from table checks)

        skip 'Warehouse database not available' unless warehouse_available?
        if warehouse_available?
          allow(Warehouse::Base).to receive(:enabled?).and_return(true)
          allow(Warehouse::CasReport).to receive(:transaction).and_yield
          allow(Warehouse::CasReport).to receive(:delete_all)
          allow(Warehouse::CasReport).to receive(:import!)
        end
      rescue ActiveRecord::StatementInvalid, PG::UndefinedTable
        skip 'Warehouse database not available'
      end

      it 'fills both reporting and warehouse tables' do
        match

        build_report.fill_cas_report_table!

        expect(Reporting::Decisions).to have_received(:delete_all)
        expect(Reporting::Decisions).to have_received(:import!)
        expect(Warehouse::CasReport).to have_received(:delete_all)
        expect(Warehouse::CasReport).to have_received(:import!)
      end
    end

    context 'when warehouse is disabled' do
      before do
        allow(Warehouse::Base).to receive(:enabled?).and_return(false)
        # Use stub_const to replace the real class with a double.
        # This prevents ActiveRecord schema introspection since it's no longer the real class.
        # We also tell it to yield when transaction is called.
        report_double = double('Warehouse::CasReport')
        allow(report_double).to receive(:transaction).and_yield
        allow(report_double).to receive(:delete_all)
        allow(report_double).to receive(:import!)
        stub_const('Warehouse::CasReport', report_double)
      end

      it 'only fills reporting table' do
        match

        build_report.fill_cas_report_table!

        expect(Reporting::Decisions).to have_received(:delete_all)
        expect(Reporting::Decisions).to have_received(:import!)
        expect(Warehouse::CasReport).not_to have_received(:delete_all)
        expect(Warehouse::CasReport).not_to have_received(:import!)
      end
    end

    it 'skips clients without id_in_data_source' do
      project_client.update(id_in_data_source: nil)
      match

      build_report.fill_cas_report_table!

      expect(Reporting::Decisions).to have_received(:import!).with([])
    end

    it 'skips matches without sub_program' do
      voucher.update(sub_program: nil)

      build_report.fill_cas_report_table!

      expect(Reporting::Decisions).to have_received(:import!).with([])
    end

    it 'skips matches without match_route' do
      program.update(match_route: nil)

      build_report.fill_cas_report_table!

      expect(Reporting::Decisions).to have_received(:import!).with([])
    end
  end

  describe '#data_source_name' do
    let(:non_hmis_data_source) { create(:data_source, :deidentified) }
    let(:hmis_data_source) { create(:data_source, :warehouse, name: 'HMIS Warehouse') }

    it 'returns Non-HMIS for deidentified data source' do
      result = build_report.data_source_name(non_hmis_data_source.id)
      expect(result).to eq('Non-HMIS')
    end

    it 'returns data source name for HMIS data source' do
      result = build_report.data_source_name(hmis_data_source.id)
      expect(result).to eq('HMIS Warehouse')
    end

    it 'returns data source id when name not found' do
      result = build_report.data_source_name(99_999)
      expect(result).to eq(99_999)
    end

    it 'memoizes non_hmis_data_source_id' do
      expect(DataSource).to receive(:where).with(db_identifier: 'Deidentified').once.and_return(double(pluck: [non_hmis_data_source.id]))

      build_report.data_source_name(non_hmis_data_source.id)
      build_report.data_source_name(non_hmis_data_source.id)
    end

    it 'memoizes data_source_names hash' do
      expect(DataSource).to receive(:pluck).with(:id, :name).once.and_return([[hmis_data_source.id, 'HMIS Warehouse']])

      build_report.data_source_name(hmis_data_source.id)
      build_report.data_source_name(hmis_data_source.id)
    end
  end

  describe '#contact_details' do
    let(:agency) { create(:agency, name: 'Test Agency') }
    let(:user) { create(:user, agency: agency) }
    let(:contact) { user.contact }

    it 'returns array of contact details' do
      result = build_report.contact_details([contact])

      expect(result).to be_an(Array)
      expect(result.first).to include(
        name: contact.name,
        email: contact.email,
        agency: 'Test Agency',
      )
    end

    it 'handles contact without user' do
      contact_without_user = create(:contact)
      contact_without_user.update(user: nil)

      result = build_report.contact_details([contact_without_user])

      expect(result.first[:agency]).to be_nil
    end

    it 'handles empty array' do
      result = build_report.contact_details([])
      expect(result).to eq([])
    end
  end

  describe '#explain' do
    let(:match) { create(:client_opportunity_match) }
    let(:decision) { create(:match_decisions_match_recommendation_dnd_staff, match: match) }

    context 'when reason is present' do
      let(:decline_reason) { create(:dnd_staff_decline_reason, name: 'Client declined') }

      before do
        decision.update(decline_reason: decline_reason)
      end

      it 'returns reason name' do
        result = build_report.explain(decision, :decline_reason)
        expect(result).to eq('Client declined')
      end

      context 'when reason is other' do
        let(:other_reason) { create(:dnd_staff_decline_reason, name: 'Other') }

        before do
          decision.update(decline_reason: other_reason, decline_reason_other_explanation: 'Custom explanation')
        end

        it 'returns reason name with explanation' do
          result = build_report.explain(decision, :decline_reason)
          expect(result).to eq('Other: Custom explanation')
        end
      end
    end

    it 'returns nil when reason is not present' do
      decision.update(decline_reason: nil)
      result = build_report.explain(decision, :decline_reason)
      expect(result).to be_nil
    end
  end

  describe '#decline_reason' do
    let(:program) { create(:program) }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:voucher) { create(:voucher, sub_program: sub_program) }
    let(:opportunity) { create(:opportunity, voucher: voucher) }
    let(:match) { create(:client_opportunity_match, match_route: program.match_route, opportunity: opportunity) }
    let(:decline_reason) { create(:dnd_staff_decline_reason, name: 'Client declined') }

    context 'when current_status is not Rejected' do
      it 'returns decline reason from decision' do
        decision = create(:match_decisions_match_recommendation_dnd_staff, match: match, decline_reason: decline_reason)
        decision_order = match.match_route.class.match_steps_for_reporting[decision.type]

        result = build_report.decline_reason(match, decision, decision_order, 'In Progress')

        expect(result).to eq('Client declined')
      end
    end

    context 'when current_status is Rejected' do
      it 'looks for decline reason in earlier decision with same order' do
        contact = create(:contact)
        # Use the auto-created decisions from the match
        earlier_decision = match.match_recommendation_shelter_agency_decision
        earlier_decision.update!(
          decline_reason: decline_reason,
          status: 'declined',
          contact: contact,
          created_at: 1.day.ago,
        )

        later_decision = match.confirm_shelter_agency_decline_dnd_staff_decision
        later_decision.update!(
          decline_reason: nil,
          status: 'decline_confirmed',
          contact: contact,
          created_at: 1.hour.ago,
        )

        match.reload # Reload to ensure decisions are loaded
        decision_order = match.match_route.class.match_steps_for_reporting[later_decision.type]

        # Verify the setup: earlier decision should have order 2, later should have order 3
        earlier_order = match.match_route.class.match_steps_for_reporting[earlier_decision.type]
        expect(earlier_order).to eq(2)
        expect(decision_order).to eq(3)
        expect(later_decision.id).to be > earlier_decision.id
        expect(earlier_decision.decline_reason).to eq(decline_reason)
        expect(later_decision.decline_reason).to be_nil
        result = build_report.decline_reason(match, later_decision, decision_order, 'Rejected')

        expect(result).to eq('Client declined')
      end
    end
  end

  describe '#attribute_to_sql' do
    it 'generates quoted SQL for attribute' do
      result = build_report.send(:attribute_to_sql, Client, :id)
      expect(result).to match(/^"clients"\."id"$/)
    end

    it 'handles different table names' do
      result = build_report.send(:attribute_to_sql, Voucher, :created_at)
      expect(result).to match(/^"vouchers"\."created_at"$/)
    end
  end
end
