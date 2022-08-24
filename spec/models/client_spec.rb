require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'prioritized' do
    let!(:clients) { create_list :client, 5 }
    context 'when prioritized by VispdatPriorityScore' do
      let(:priority) { create :priority_vispdat_priority }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by vispdat_priority_score' do
        clients.first(2).map { |m| m.update(vispdat_priority_score: nil) }
        expect(Client.prioritized(route, Client.all)).to eq Client.where.not(vispdat_priority_score: nil).order(vispdat_priority_score: :desc)
      end
    end
    context 'when prioritized by VispdatScore' do
      let(:priority) { create :priority_vispdat }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by vispdat_score' do
        clients.first(2).map { |m| m.update(vispdat_score: nil) }
        expect(Client.prioritized(route, Client.all)).to eq Client.where.not(vispdat_score: nil).order(vispdat_score: :desc)
      end
    end

    context 'when prioritized by DaysHomelessLastThreeYears' do
      let(:priority) { create :priority_days_homeless_last_three_years }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by days_homeless_in_last_three_years' do
        expect(Client.prioritized(route, Client.all)).to eq Client.order(days_homeless_in_last_three_years: :desc)
      end
    end

    context 'when prioritized by DaysHomeless' do
      let(:priority) { create :priority_days_homeless }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by days_homeless' do
        expect(Client.prioritized(route, Client.all)).to eq Client.order(days_homeless: :desc)
      end
    end

    context 'when prioritized by AssessmentScore' do
      let(:priority) { create :priority_assessment_score }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by assessment_score' do
        expect(Client.prioritized(route, Client.all).pluck(:id, :assessment_score, :days_homeless)).to eq Client.order(assessment_score: :desc, rrh_assessment_collected_at: :desc).pluck(:id, :assessment_score, :days_homeless)
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
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by assessment_score' do
        ordered_clients = Client.order(assessment_score: :desc, tie_breaker_date: :asc).pluck(:id, :assessment_score, :tie_breaker_date)
        expect(Client.prioritized(route, Client.all).pluck(:id, :assessment_score, :tie_breaker_date)).to eq(ordered_clients)
        expect(Client.prioritized(route, Client.all).first(2).map(&:assessment_score).uniq.count).to eq(1)
      end
    end

    context 'when prioritized by DaysHomelessLastThreeYears assessment date tie breaker' do
      let(:priority) { create :priority_days_homeless_last_three_years_assessment_date }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by days_homeless_in_last_three_years' do
        ordered_clients = Client.order(days_homeless_in_last_three_years: :desc, entry_date: :asc, tie_breaker: :asc).pluck(:id, :days_homeless_in_last_three_years, :entry_date, :tie_breaker)
        expect(Client.prioritized(route, Client.all).pluck(:id, :days_homeless_in_last_three_years, :entry_date, :tie_breaker)).to eq(ordered_clients)
      end
    end

    context 'when prioritized by MatchGroup' do
      let(:priority) { create :priority_match_group }
      let(:route) { create :default_route, match_prioritization: priority }
      it 'is an ActiveRecord::Relation' do
        expect(Client.prioritized(route, Client.all)).to be_an ActiveRecord::Relation
      end
      it 'orders by match_group, then by entry_date, then by vispdat_score' do
        clients[2].update(match_group: 1, entry_date: 1.year.ago, vispdat_score: 100) # 1 (vispdat tie breaker)
        clients[3].update(match_group: 1, entry_date: 1.year.ago, vispdat_score: 10) # 2
        clients[4].update(match_group: 1, entry_date: 1.week.ago, vispdat_score: 10) # 3 (entry date)
        clients[0].update(match_group: 3, entry_date: 1.month.ago, vispdat_score: nil) # 4 (entry date)
        clients[1].update(match_group: 3, entry_date: Date.today, vispdat_score: 100) # 5

        ordered_clients = [clients[2], clients[3], clients[4], clients[0], clients[1]].pluck(:id, :match_group, :entry_date, :vispdat_score)
        prioritized_clients = Client.prioritized(route, Client.all).pluck(:id, :match_group, :entry_date, :vispdat_score)
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
end
