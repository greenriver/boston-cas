###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'prioritized' do
    let!(:clients) { create_list :client, 5 }
    context 'when prioritized by VispdatPriorityScore' do
      let(:priority) { create :priority_vispdat_priority }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by vispdat_priority_score' do
        clients.first(2).map { |m| m.update(vispdat_priority_score: nil) }
        expect(Client.prioritized(route.match_prioritization, Client.all)).to eq Client.where.not(vispdat_priority_score: nil).order(vispdat_priority_score: :desc)
      end
    end
    context 'when prioritized by VispdatScore' do
      let(:priority) { create :priority_vispdat }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by vispdat_score' do
        clients.first(2).map { |m| m.update(vispdat_score: nil) }
        expect(Client.prioritized(route.match_prioritization, Client.all)).to eq Client.where.not(vispdat_score: nil).order(vispdat_score: :desc)
      end
    end

    context 'when prioritized by DaysHomelessLastThreeYears' do
      let(:priority) { create :priority_days_homeless_last_three_years }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by days_homeless_in_last_three_years' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to eq Client.order(days_homeless_in_last_three_years: :desc)
      end
    end

    context 'when prioritized by DaysHomeless' do
      let(:priority) { create :priority_days_homeless }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by days_homeless' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to eq Client.order(days_homeless: :desc)
      end
    end

    context 'when prioritized by AssessmentScore' do
      let(:priority) { create :priority_assessment_score }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by assessment_score' do
        expect(Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :assessment_score, :days_homeless)).to eq Client.order(assessment_score: :desc, rrh_assessment_collected_at: :desc).pluck(:id, :assessment_score, :days_homeless)
      end
    end

    context 'when prioritized by AssessmentScore with funding tie breaker' do
      let(:priority) { create :priority_assessment_score_funding_tie_breaker }
      let(:route) { create :default_route, match_prioritization: priority }
      before :each do
        # set the two top scores to the same thing, make sure we get the client with the earliest tie_breaker_date (closest to running out of funding)
        # as the highest priority
        highest_scores = clients.sort_by(&:assessment_score).last(2)
        top_score = highest_scores.map(&:assessment_score).max
        # make they don't both have the same day
        top_date = highest_scores.map(&:tie_breaker_date).min
        highest_scores.each.with_index { |c, i| c.update(assessment_score: top_score, tie_breaker_date: top_date - i.days) }
      end
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by assessment_score' do
        ordered_clients = Client.order(assessment_score: :desc, tie_breaker_date: :asc).pluck(:id, :assessment_score, :tie_breaker_date)
        expect(Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :assessment_score, :tie_breaker_date)).to eq(ordered_clients)
        expect(Client.prioritized(route.match_prioritization, Client.all).first(2).map(&:assessment_score).uniq.count).to eq(1)
      end
    end

    context 'when prioritized by AssessmentScore with random tie breaker' do
      let(:priority) { create :priority_assessment_score_random_tie_breaker }
      let(:route) { create :default_route, match_prioritization: priority }
      before :each do
        # set the two top scores to the same thing, make sure we get the client with the lowest tie breaker
        # as the highest priority
        highest_scores = clients.sort_by(&:assessment_score).last(2)
        top_score = highest_scores.map(&:assessment_score).max
        highest_scores.each { |c| c.update(assessment_score: top_score) }
      end
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by assessment_score' do
        ordered_clients = Client.order(assessment_score: :desc, tie_breaker: :asc).pluck(:id, :assessment_score, :tie_breaker)
        expect(Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :assessment_score, :tie_breaker)).to eq(ordered_clients)
        expect(Client.prioritized(route.match_prioritization, Client.all).first(2).map(&:assessment_score).uniq.count).to eq(1)
      end
    end

    context 'when prioritized by DaysHomelessLastThreeYears assessment date tie breaker' do
      let(:priority) { create :priority_days_homeless_last_three_years_assessment_date }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by days_homeless_in_last_three_years' do
        ordered_clients = Client.order(days_homeless_in_last_three_years: :desc, entry_date: :asc, tie_breaker: :asc).pluck(:id, :days_homeless_in_last_three_years, :entry_date, :tie_breaker)
        expect(Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :days_homeless_in_last_three_years, :entry_date, :tie_breaker)).to eq(ordered_clients)
      end
    end

    context 'when prioritized by MatchGroup' do
      let(:priority) { create :priority_match_group_disability }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by match_group' do
        clients[2].update(match_group: 1, chronic_homeless: true)
        clients[3].update(match_group: 1)
        clients[4].update(match_group: 2)
        clients[0].update(match_group: 3, chronic_homeless: true)
        clients[1].update(match_group: 3)

        ordered_clients = [clients[2], clients[3], clients[4], clients[0], clients[1]].pluck(:id, :match_group, :chronic_homeless)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :match_group, :chronic_homeless)
        expect(prioritized_clients).to eq(ordered_clients)
      end
      it 'secondary sort by veteran and chronic' do
        clients.each { |c| c.update(match_group: 1) }
        clients[2].update(veteran: true, chronic_homeless: true, days_homeless: 20)
        clients[3].update(veteran: true, chronic_homeless: false, days_homeless: 30)
        clients[4].update(veteran: false, chronic_homeless: true, days_homeless: 20)
        clients[0].update(veteran: false, chronic_homeless: false, days_homeless: 30)
        clients[1].update(veteran: nil, chronic_homeless: false, days_homeless: 20)

        ordered_clients = [clients[2], clients[3], clients[4], clients[0], clients[1]].pluck(:id, :chronic_homeless, :days_homeless)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :chronic_homeless, :days_homeless)
        expect(prioritized_clients).to eq(ordered_clients)
      end
      it 'tie breaks on days_homeless' do
        clients.each { |c| c.update(match_group: 2, veteran: true, chronic_homeless: true) }
        clients[2].update(days_homeless: 101)
        clients[3].update(days_homeless: 100)
        clients[4].update(days_homeless: 90)
        clients[0].update(days_homeless: 1)
        clients[1].update(days_homeless: 0)

        ordered_clients = [clients[2], clients[3], clients[4], clients[0], clients[1]].pluck(:id, :chronic_homeless, :days_homeless)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :chronic_homeless, :days_homeless)
        expect(prioritized_clients).to eq(ordered_clients)
      end
      it 'places nulls last in sort order' do
        clients.each { |c| c.update(match_group: 1) }
        clients[2].update(chronic_homeless: true, days_homeless: 101)
        clients[3].update(chronic_homeless: true, days_homeless: 100)
        clients[4].update(chronic_homeless: true, days_homeless: nil)
        clients[0].update(chronic_homeless: true, days_homeless: 10)
        clients[1].update(chronic_homeless: nil, days_homeless: nil)

        ordered_clients = [clients[2], clients[3], clients[0], clients[4], clients[1]].pluck(:id, :chronic_homeless, :days_homeless)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(:id, :chronic_homeless, :days_homeless)
        expect(prioritized_clients).to eq(ordered_clients)
      end
    end

    context 'when prioritized by FamilyPsh' do
      let(:priority) { create :priority_family_psh }
      let(:route) { create :default_route, match_prioritization: priority }
      let(:expected_order) do
        tie_breaker_base = 1.years.ago.to_date
        {
          2 => {
            total_homeless_nights_unsheltered: 1,
            days_homeless_in_last_three_years: 10,
            tie_breaker_date: tie_breaker_base,
          },
          4 => {
            service_need: true,
            household_dv_survivor: true,
            days_homeless_in_last_three_years: 9,
            tie_breaker_date: tie_breaker_base - 1.days,
          },
          1 => {
            total_homeless_nights_unsheltered: 1,
            days_homeless_in_last_three_years: 9,
            tie_breaker_date: tie_breaker_base,
          },
          3 => {
            service_need: true,
            enrolled_in_th: true,
            days_homeless_in_last_three_years: 11,
            tie_breaker_date: tie_breaker_base,
          },
          0 => {
            days_homeless_in_last_three_years: 5,
            tie_breaker_date: tie_breaker_base + 1.days,
          },
        }
      end
      let(:columns) do
        [
          :total_homeless_nights_unsheltered,
          :service_need,
          :household_dv_survivor,
          :enrolled_in_th,
          :days_homeless_in_last_three_years,
          :tie_breaker_date,
        ]
      end
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by match_group' do
        expected_order.each do |i, values|
          clients[i].update(**values)
        end
        ordered_clients = expected_order.keys.map { |i| clients[i] }.pluck(*columns)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(*columns)
        expect(prioritized_clients).to eq(ordered_clients)
      end
    end

    context 'when prioritized by RrhAndTh' do
      let(:priority) { create :priority_rrh_and_th }
      let(:route) { create :default_route, match_prioritization: priority }
      let(:expected_order) do
        tie_breaker_base = 1.years.ago.to_date
        {
          2 => {
            total_homeless_nights_unsheltered: 1,
            days_homeless_in_last_three_years: 10,
            tie_breaker_date: tie_breaker_base,
          },
          4 => {
            disqualified_for_state_assistance: true,
            household_dv_survivor: true,
            days_homeless_in_last_three_years: 9,
            tie_breaker_date: tie_breaker_base - 1.days,
          },
          1 => {
            total_homeless_nights_unsheltered: 1,
            days_homeless_in_last_three_years: 9,
            tie_breaker_date: tie_breaker_base,
          },
          3 => {
            disqualified_for_state_assistance: true,
            enrolled_in_th: true,
            days_homeless_in_last_three_years: 11,
            tie_breaker_date: tie_breaker_base,
          },
          0 => {
            days_homeless_in_last_three_years: 5,
            tie_breaker_date: tie_breaker_base + 1.days,
          },
        }
      end
      let(:columns) do
        [
          :total_homeless_nights_unsheltered,
          :disqualified_for_state_assistance,
          :household_dv_survivor,
          :enrolled_in_th,
          :days_homeless_in_last_three_years,
          :tie_breaker_date,
        ]
      end
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by match_group' do
        expected_order.each do |i, values|
          clients[i].update(**values)
        end
        ordered_clients = expected_order.keys.map { |i| clients[i] }.pluck(*columns)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(*columns)
        expect(prioritized_clients).to eq(ordered_clients)
      end
    end

    context 'when prioritized by LowIncomeSubsidies' do
      let(:priority) { create :priority_low_income_subsidies }
      let(:route) { create :default_route, match_prioritization: priority }
      let(:expected_order) do
        tie_breaker_base = 1.years.ago.to_date
        {
          2 => {
            total_homeless_nights_unsheltered: 1,
            days_homeless_in_last_three_years: 10,
            tie_breaker_date: tie_breaker_base,
          },
          4 => {
            housing_barrier: true,
            household_dv_survivor: true,
            days_homeless_in_last_three_years: 9,
            tie_breaker_date: tie_breaker_base - 1.days,
          },
          1 => {
            total_homeless_nights_unsheltered: 1,
            days_homeless_in_last_three_years: 9,
            tie_breaker_date: tie_breaker_base,
          },
          3 => {
            housing_barrier: true,
            enrolled_in_th: true,
            days_homeless_in_last_three_years: 11,
            tie_breaker_date: tie_breaker_base,
          },
          0 => {
            days_homeless_in_last_three_years: 5,
            tie_breaker_date: tie_breaker_base + 1.days,
          },
        }
      end
      let(:columns) do
        [
          :total_homeless_nights_unsheltered,
          :housing_barrier,
          :household_dv_survivor,
          :enrolled_in_th,
          :days_homeless_in_last_three_years,
          :tie_breaker_date,
        ]
      end
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route.match_prioritization, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by match_group' do
        expected_order.each do |i, values|
          clients[i].update(**values)
        end
        ordered_clients = expected_order.keys.map { |i| clients[i] }.pluck(*columns)
        prioritized_clients = Client.prioritized(route.match_prioritization, Client.all).pluck(*columns)
        expect(prioritized_clients).to eq(ordered_clients)
      end
    end
  end

  let(:bob_smith) { create :client, first_name: 'Bob', last_name: 'Smith' }
  let(:joe_smith) { create :client, first_name: 'Joe', last_name: 'Smith' }
  let(:ray_jones) { create :client, first_name: 'Ray', last_name: 'Jones' }
  let(:ray_clark) { create :client, first_name: 'Ray', last_name: 'Clark' }
  let(:ben_chris) { create :client, first_name: 'Ben', last_name: 'Chris', alternate_names: 'Bobby Ray,Lee Jones' }
  let(:billybob_desmith) { create :client, first_name: 'Billybob', last_name: 'DeSmith' }
  let(:clients) { [bob_smith, joe_smith, ray_jones, ray_clark, ben_chris, billybob_desmith] }
  let(:match_bob) { Client.where(Client.search_first_name('Bob')) }
  let(:match_ray) { Client.text_search('Ray') }
  describe 'search_first_name' do
    before(:each) do
      clients
    end
    context 'when searching Bob' do
      it 'matches one' do
        expect(match_bob.count).to eq 1
      end
      it 'matches Bob' do
        expect(match_bob).to include bob_smith
      end
      it 'does not match Joe Smith' do
        expect(match_bob).to_not include joe_smith, billybob_desmith
      end
    end
  end

  let(:match_smith) { Client.where(Client.search_last_name('Smith')) }

  describe 'search_last_name' do
    before(:each) do
      clients
    end
    context 'when searching Smith' do
      it 'matches 2' do
        expect(match_smith.count).to eq 2
      end
      it 'matches Bob' do
        expect(match_smith).to include bob_smith
      end
      it 'matches Joe' do
        expect(match_smith).to include joe_smith
      end
      it 'does not match either Rays' do
        expect(match_smith).to_not include ray_jones, ray_clark, billybob_desmith
      end
    end
  end

  let(:match_alternate_jones) { Client.where(Client.search_alternate_name('Jones')) }

  describe 'search_alternate_name' do
    before(:each) do
      clients
    end
    context 'when searching Jones' do
      it 'matches 1' do
        expect(match_alternate_jones.count).to eq 1
      end
      it 'matches Ben' do
        expect(match_alternate_jones).to include ben_chris
      end
      it 'does not match anyone else' do
        expect(match_alternate_jones).to_not include(*(clients - [ben_chris]))
      end
    end
  end

  describe 'search text search' do
    before(:each) do
      clients
    end
    context 'when searching Ray' do
      it 'matches three (two in first name, one in alternate names' do
        expect(match_ray.count).to eq 3
      end
      it 'matches Ray' do
        expect(match_ray).to include ray_jones
      end
      it 'does not match Joe Smith' do
        expect(match_ray).to_not include joe_smith
      end
    end
  end

  let(:ray_search) do
    Client.where(
      Client.search_first_name('Ray').
      or(Client.search_alternate_name('Ray')),
    )
  end
  let(:bob_search) do
    Client.where(
      Client.search_first_name('Bob').
      or(Client.search_alternate_name('Bob')),
    )
  end

  describe 'combo match on first & alternate' do
    before(:each) do
      clients
    end
    context 'when searching Ray' do
      it 'matches 3' do
        expect(ray_search.count).to eq 3
      end
    end
    context 'when searching Bob' do
      it 'matches 2' do
        expect(bob_search.count).to eq 2
      end
    end
  end

  describe 'editable_by' do
    let(:admin_role) { create :admin_role }
    let(:limited_client_editor_role) { create :limited_client_viewer }
    let(:admin_user) { create :user, roles: [admin_role] }
    let(:limited_user) { create :user, roles: [limited_client_editor_role] }
    let(:regular_user) { create :user }
    let!(:client1) { create :client }
    let!(:client2) { create :client }

    context 'when user can edit all clients' do
      it 'returns all clients' do
        expect(Client.editable_by(admin_user).count).to eq(2)
        expect(Client.editable_by(admin_user).pluck(:id).sort).to eq([client1.id, client2.id].sort)
      end
    end

    context 'when user has edit permissions based on rules' do
      let(:rule) { create :age_greater_than_sixty }
      let(:requirement) { create :requirement, rule: rule, positive: true }

      before do
        client1.update(date_of_birth: 70.years.ago)
        client2.update(date_of_birth: 20.years.ago)
        limited_user.requirements << requirement
      end

      it 'returns only matching clients' do
        expect(Client.editable_by(limited_user).count).to eq(1)
        expect(Client.editable_by(limited_user).pluck(:id)).to eq([client1.id])
      end
    end

    context 'when user has no edit permissions' do
      it 'returns no clients' do
        expect(Client.editable_by(regular_user).count).to eq(0)
      end
    end
  end

  describe 'accessible_by_user' do
    let(:admin_role) { create :admin_role }
    let(:limited_client_viewer_role) { create :limited_client_viewer }
    let(:admin_user) { create :user, roles: [admin_role] }
    let(:limited_user) { create :user, roles: [limited_client_viewer_role] }
    let(:regular_user) { create :user }
    let!(:client1) { create :client }
    let!(:client2) { create :client }

    context 'when user can view all clients' do
      it 'returns all clients' do
        expect(Client.accessible_by_user(admin_user).count).to eq(2)
        expect(Client.accessible_by_user(admin_user).pluck(:id).sort).to eq([client1.id, client2.id].sort)
      end
    end

    context 'when user has view permissions based on rules' do
      let(:rule) { create :age_greater_than_sixty }
      let(:requirement) { create :requirement, rule: rule, positive: true }

      before do
        client1.update(date_of_birth: 70.years.ago)
        client2.update(date_of_birth: 20.years.ago)
        limited_user.requirements << requirement
      end

      it 'returns only matching clients' do
        expect(Client.accessible_by_user(limited_user).count).to eq(1)
        expect(Client.accessible_by_user(limited_user).pluck(:id)).to eq([client1.id])
      end
    end

    context 'when user has no view permissions' do
      it 'returns no clients' do
        expect(Client.accessible_by_user(regular_user).count).to eq(0)
      end
    end
  end

  describe 'accessible_by_user?' do
    let(:admin_role) { create :admin_role }
    let(:limited_client_viewer_role) { create :limited_client_viewer }
    let(:admin_user) { create :user, roles: [admin_role] }
    let(:limited_user) { create :user, roles: [limited_client_viewer_role] }
    let(:regular_user) { create :user }
    let(:client) { create :client }

    context 'when user can view all clients' do
      it 'returns true' do
        expect(client.accessible_by_user?(admin_user)).to be true
      end
    end

    context 'when user has view permissions based on rules' do
      let(:rule) { create :age_greater_than_sixty }
      let(:requirement) { create :requirement, rule: rule, positive: true }

      before do
        client.update(date_of_birth: 70.years.ago)
        limited_user.requirements << requirement
      end

      it 'returns true for matching client' do
        expect(client.accessible_by_user?(limited_user)).to be true
      end

      it 'returns false for non-matching client' do
        client.update(date_of_birth: 20.years.ago)
        expect(client.accessible_by_user?(limited_user)).to be false
      end
    end

    context 'when user has no view permissions' do
      it 'returns false' do
        expect(client.accessible_by_user?(regular_user)).to be false
      end
    end
  end

  describe 'editable_by?' do
    let(:admin_role) { create :admin_role }
    let(:limited_client_editor_role) { create :limited_client_viewer }
    let(:admin_user) { create :user, roles: [admin_role] }
    let(:limited_user) { create :user, roles: [limited_client_editor_role] }
    let(:regular_user) { create :user }
    let(:client) { create :client }

    context 'when user can edit all clients' do
      it 'returns true' do
        expect(client.editable_by?(admin_user)).to be true
      end
    end

    context 'when user has edit permissions based on rules' do
      let(:rule) { create :age_greater_than_sixty }
      let(:requirement) { create :requirement, rule: rule, positive: true }

      before do
        client.update(date_of_birth: 70.years.ago)
        limited_user.requirements << requirement
      end

      it 'returns true for matching client' do
        expect(client.editable_by?(limited_user)).to be true
      end

      it 'returns false for non-matching client' do
        client.update(date_of_birth: 20.years.ago)
        expect(client.editable_by?(limited_user)).to be false
      end
    end

    context 'when user has no edit permissions' do
      it 'returns false' do
        expect(client.editable_by?(regular_user)).to be false
      end
    end
  end

  describe 'remote_client_visible_to?' do
    let!(:user_agency) { create(:agency, name: 'User Test Agency') }
    let!(:other_agency) { create(:agency, name: 'Other Test Agency') }
    let!(:deidentified_data_source) { create(:data_source, :deidentified) } # Defined once

    let!(:admin_role) { create(:role, name: 'remote_client_test_admin_editor', can_edit_all_clients: true) }
    let!(:admin_user) { create(:user, agency: user_agency, roles: [admin_role]) }

    let!(:basic_role) { create(:role, name: 'remote_client_test_basic_user') } # No special global perms
    let!(:basic_user_in_user_agency) { create(:user, agency: user_agency, roles: [basic_role]) }
    let!(:basic_user_in_other_agency) { create(:user, agency: other_agency, roles: [basic_role]) }

    let!(:deid_manager_role) { create(:role, name: 'remote_client_test_deid_manager', can_manage_all_deidentified_clients: true) }
    let!(:deid_viewer) { create(:user, agency: user_agency, roles: [deid_manager_role]) }

    let!(:id_manager_role) { create(:role, name: 'remote_client_test_id_manager', can_manage_all_identified_clients: true) }
    let!(:identified_viewer) { create(:user, agency: user_agency, roles: [id_manager_role]) }

    let!(:imp_manager_role) { create(:role, name: 'remote_client_test_imp_manager', can_manage_imported_clients: true) }
    let!(:imported_viewer) { create(:user, agency: user_agency, roles: [imp_manager_role]) }

    let!(:client_under_test) do
      client = create(:client)
      # Ensure project_client exists and has the correct data_source_id for NonHmis related records
      create(:project_client, client_id: client.id, data_source_id: deidentified_data_source.id)
      client
    end

    # Helper to link client_under_test's project_client to a specific NonHmisClient record
    # This NonHmisClient record's `identified` boolean will drive ProjectClient#is_identified?/is_deidentified?
    # and its ID will be used as `remote_id` in the visibility check loop.
    def link_project_client_to_remote_record(client_obj, remote_record_instance)
      pc = client_obj.project_client
      # Ensure data_source_id is correct for NonHmisClient types, matching what project_client was created with.
      # This assumes DeidentifiedClient, IdentifiedClient, ImportedClient all use this deidentified_data_source
      expected_non_hmis_ds_id = deidentified_data_source.id

      unless pc.data_source_id == expected_non_hmis_ds_id
        # Fail fast if there's a mismatch, as it indicates a setup problem for these tests.
        raise "ProjectClient data_source_id mismatch: PC has #{pc.data_source_id}, expected NonHmis DS ID is #{expected_non_hmis_ds_id}"
      end

      pc.update!(id_in_data_source: remote_record_instance.id)
      client_obj.reload # Crucial for client.remote_id and project_client states
    end

    context 'when project_client is not effectively linked to a NonHmisClient (making is_deidentified? and is_identified? both false)' do
      before do
        # Ensure project_client.id_in_data_source points to nothing, making actual_remote_record nil
        # (assuming ProjectClient#is_identified?/is_deidentified? rely on actual_remote_record)
        client_under_test.project_client.update!(id_in_data_source: -999) # Non-existent ID
        client_under_test.reload
      end

      it 'returns true (due to the `unless` condition in the method)' do
        # This tests the first return path: `return true unless project_client.is_deidentified? || project_client.is_identified?`
        expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
      end
    end

    context 'when project_client is linked to an actual NonHmisClient record' do
      # These contexts test the main loop logic where is_deidentified? OR is_identified? is true.

      context 'and linked to a DeidentifiedClient (record.identified == false)' do
        let!(:deid_visible_to_basic) { create(:deidentified_client, agency: user_agency, identified: false) }
        let!(:deid_invisible_to_basic) { create(:deidentified_client, agency: other_agency, identified: false) }
        let!(:deid_for_admin) { create(:deidentified_client, agency: other_agency, identified: false) }
        let!(:deid_for_deid_viewer) { create(:deidentified_client, agency: other_agency, identified: false) }

        it 'returns true if linked DeidentifiedClient is visible to basic_user_in_user_agency' do
          link_project_client_to_remote_record(client_under_test, deid_visible_to_basic)
          expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
        end

        it 'returns false if linked DeidentifiedClient is not visible to basic_user_in_user_agency (and no other types match for this ID)' do
          link_project_client_to_remote_record(client_under_test, deid_invisible_to_basic)
          # Ensure no other client types with this ID could grant visibility
          IdentifiedClient.where(id: deid_invisible_to_basic.id).destroy_all
          ImportedClient.where(id: deid_invisible_to_basic.id).destroy_all
          expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be false
        end

        it 'returns true if linked DeidentifiedClient is visible to admin_user' do
          link_project_client_to_remote_record(client_under_test, deid_for_admin)
          expect(client_under_test.remote_client_visible_to?(admin_user)).to be true
        end

        it 'returns true if linked DeidentifiedClient is visible to deid_viewer' do
          link_project_client_to_remote_record(client_under_test, deid_for_deid_viewer)
          expect(client_under_test.remote_client_visible_to?(deid_viewer)).to be true
        end
      end

      context 'and linked to an IdentifiedClient (record.identified == true)' do
        let!(:id_visible_to_basic) { create(:identified_client, agency: user_agency, identified: true) }
        let!(:id_invisible_to_basic) { create(:identified_client, agency: other_agency, identified: true) }
        let!(:id_for_admin) { create(:identified_client, agency: other_agency, identified: true) }
        let!(:id_for_id_viewer) { create(:identified_client, agency: other_agency, identified: true) }

        it 'returns true if linked IdentifiedClient is visible to basic_user_in_user_agency' do
          link_project_client_to_remote_record(client_under_test, id_visible_to_basic)
          expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
        end

        it 'returns false if linked IdentifiedClient is not visible to basic_user_in_user_agency (and no other types match)' do
          link_project_client_to_remote_record(client_under_test, id_invisible_to_basic)
          DeidentifiedClient.where(id: id_invisible_to_basic.id).destroy_all
          ImportedClient.where(id: id_invisible_to_basic.id).destroy_all
          expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be false
        end

        it 'returns true if linked IdentifiedClient is visible to admin_user' do
          link_project_client_to_remote_record(client_under_test, id_for_admin)
          expect(client_under_test.remote_client_visible_to?(admin_user)).to be true
        end

        it 'returns true if linked IdentifiedClient is visible to identified_viewer' do
          link_project_client_to_remote_record(client_under_test, id_for_id_viewer)
          expect(client_under_test.remote_client_visible_to?(identified_viewer)).to be true
        end
      end

      context 'and linked to an ImportedClient' do
        # The ImportedClient.all scope is used, so its own `identified` status does not affect this specific scope's filtering.
        # However, its `identified` status DOES affect ProjectClient#is_identified?/is_deidentified?,
        # determining if we enter the loop.

        context 'when the ImportedClient record has identified: false (making ProjectClient deidentified)' do
          let!(:imp_deid_visible_to_basic) { create(:imported_client, agency: user_agency, identified: false) }
          let!(:imp_deid_invisible_to_basic) { create(:imported_client, agency: other_agency, identified: false) }

          it 'returns true if linked (deidentified) ImportedClient is visible to basic_user_in_user_agency' do
            link_project_client_to_remote_record(client_under_test, imp_deid_visible_to_basic)
            expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
          end

          it 'returns false if linked (deidentified) ImportedClient is not visible (and others do not match)' do
            link_project_client_to_remote_record(client_under_test, imp_deid_invisible_to_basic)
            DeidentifiedClient.where(id: imp_deid_invisible_to_basic.id).destroy_all
            IdentifiedClient.where(id: imp_deid_invisible_to_basic.id).destroy_all
            expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be false
          end
        end

        context 'when the ImportedClient record has identified: true (making ProjectClient identified)' do
          let!(:imp_id_visible_to_basic) { create(:imported_client, agency: user_agency, identified: true) }
          let!(:imp_id_invisible_to_basic) { create(:imported_client, agency: other_agency, identified: true) }

          it 'returns true if linked (identified) ImportedClient is visible to basic_user_in_user_agency' do
            link_project_client_to_remote_record(client_under_test, imp_id_visible_to_basic)
            expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
          end

          it 'returns false if linked (identified) ImportedClient is not visible (and others do not match)' do
            link_project_client_to_remote_record(client_under_test, imp_id_invisible_to_basic)
            DeidentifiedClient.where(id: imp_id_invisible_to_basic.id).destroy_all
            IdentifiedClient.where(id: imp_id_invisible_to_basic.id).destroy_all
            expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be false
          end
        end

        it 'returns true if linked ImportedClient is visible to admin_user' do
          imp_for_admin = create(:imported_client, agency: other_agency, identified: true) # identified status for initial check
          link_project_client_to_remote_record(client_under_test, imp_for_admin)
          expect(client_under_test.remote_client_visible_to?(admin_user)).to be true
        end

        it 'returns true if linked ImportedClient is visible to imported_viewer' do
          imp_for_viewer = create(:imported_client, agency: other_agency, identified: false) # identified status for initial check
          link_project_client_to_remote_record(client_under_test, imp_for_viewer)
          expect(client_under_test.remote_client_visible_to?(imported_viewer)).to be true
        end
      end

      # Test the OR logic of the .any? block
      it 'returns true if remote_id matches a visible DeidentifiedClient, even if an IdentifiedClient with same ID would not be visible' do
        # Setup: PC linked to a DeidentifiedClient that IS visible
        visible_deid = create(:deidentified_client, agency: user_agency, identified: false)
        link_project_client_to_remote_record(client_under_test, visible_deid)

        expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
      end

      it 'returns true if remote_id matches a visible IdentifiedClient, after a DeidentifiedClient with same ID was not visible' do
        # Setup: PC linked to an IdentifiedClient that IS visible
        visible_id = create(:identified_client, agency: user_agency, identified: true)
        link_project_client_to_remote_record(client_under_test, visible_id)

        expect(client_under_test.remote_client_visible_to?(basic_user_in_user_agency)).to be true
      end
    end
  end

  describe '#active_match_on_route?' do
    let(:client) { create(:client) }
    let(:priority) { create(:priority_vispdat_priority) }
    let(:default_route) { create(:default_route, match_prioritization: priority) }
    let(:provider_route) { create(:provider_route, match_prioritization: priority) }
    let(:program_default) { create(:program, match_route: default_route) }
    let(:program_provider) { create(:program, match_route: provider_route) }
    let(:sub_program_default) { create(:sub_program, program: program_default) }
    let(:sub_program_provider) { create(:sub_program, program: program_provider) }
    let(:voucher_default) { create(:voucher, sub_program: sub_program_default) }
    let(:voucher_provider) { create(:voucher, sub_program: sub_program_provider) }
    let(:opportunity_default) { create(:opportunity, voucher: voucher_default) }
    let(:opportunity_provider) { create(:opportunity, voucher: voucher_provider) }

    context 'when client has no matches' do
      it 'returns false' do
        expect(client.active_match_on_route?(default_route)).to be false
      end
    end

    context 'when client has an active match on the route' do
      let!(:active_match) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity_default,
          match_route: default_route,
          active: true,
          closed: false,
        )
      end

      it 'returns true for the route with the active match' do
        expect(client.active_match_on_route?(default_route)).to be true
      end

      it 'returns false for a different route' do
        expect(client.active_match_on_route?(provider_route)).to be false
      end
    end

    context 'when client has a closed match on the route' do
      let!(:closed_match) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity_default,
          match_route: default_route,
          active: false,
          closed: true,
        )
      end

      it 'returns false' do
        expect(client.active_match_on_route?(default_route)).to be false
      end
    end

    context 'when client has active matches on multiple routes' do
      let!(:active_match_default) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity_default,
          match_route: default_route,
          active: true,
          closed: false,
        )
      end

      let!(:active_match_provider) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity_provider,
          match_route: provider_route,
          active: true,
          closed: false,
        )
      end

      it 'returns true for each route with an active match' do
        aggregate_failures 'checking multiple routes' do
          expect(client.active_match_on_route?(default_route)).to be true
          expect(client.active_match_on_route?(provider_route)).to be true
        end
      end
    end

    context 'when client has an inactive match on the route' do
      let!(:inactive_match) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity_default,
          match_route: default_route,
          active: false,
          closed: false,
        )
      end

      it 'returns false' do
        expect(client.active_match_on_route?(default_route)).to be false
      end
    end
  end

  # Regression coverage for the StreetAddress 1.x → 2.x major upgrade.
  # Client#line_1_for_export, #city_for_export, #state_for_export, and
  # #postal_code_for_export all delegate to StreetAddress::US.parse. If the
  # gem's public API changed (attribute names, parse return type, etc.) these
  # methods would silently return nil in every CSV/report export.
  describe 'address export methods' do
    subject(:client) { build(:client, address: '123 Main St, Boston, MA 02101') }

    it 'parses the street line' do
      expect(client.line_1_for_export).to eq('123 Main St')
    end

    it 'parses the city' do
      expect(client.city_for_export).to eq('Boston')
    end

    it 'parses the state' do
      expect(client.state_for_export).to eq('MA')
    end

    it 'parses the postal code' do
      expect(client.postal_code_for_export).to eq('02101')
    end

    context 'when the address cannot be parsed' do
      subject(:client) { build(:client, address: 'unknown location') }

      it 'falls back to the raw address string for line 1' do
        expect(client.line_1_for_export).to eq('unknown location')
      end

      it 'returns nil for city' do
        expect(client.city_for_export).to be_nil
      end
    end

    context 'when address is nil' do
      subject(:client) { build(:client, address: nil) }

      it 'returns nil for all fields without raising' do
        expect(client.line_1_for_export).to be_nil
        expect(client.city_for_export).to be_nil
        expect(client.state_for_export).to be_nil
        expect(client.postal_code_for_export).to be_nil
      end
    end
  end
end
