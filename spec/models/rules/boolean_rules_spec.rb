require 'rails_helper'

RSpec.describe Rules::DrugTest, type: :model do
  [
    :asylee,
    :child_in_household,
    :drug_test,
    :employed_three_months,
    :health_prioritized,
    :heavy_drug_use,
    :housing_for_formerly_homeless,
    :lifetime_sex_offender,
    :living_wage,
    :meth_production_conviction,
    :open_case,
    :physical_disability,
    :sober,
    :sro_ok,
    :ssvf_eligible,
    :us_citizen,
    :va_eligible,
    :vash_eligible,
    :veteran,
    :willing_case_management,
    :need_daily_assistance,
    :full_time_employed,
    :can_work_full_time,
    :willing_to_work_full_time,
    :rrh_successful_exit,
    :th_desired,
    :site_case_management_required,
    :ongoing_case_management_required,
  ].each do |boolean_rule|
    describe "clients that fit #{boolean_rule}" do
      let!(:rule) { create boolean_rule }

      let!(:bob) { create :client, first_name: 'Bob', boolean_rule => true }
      let!(:roy) { create :client, first_name: 'Roy', boolean_rule => false }

      let!(:positive) { create :requirement, rule: rule, positive: true }
      let!(:negative) { create :requirement, rule: rule, positive: false }

      let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
      let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

      context 'when positive' do
        it 'matches 1' do
          expect(clients_that_fit.count).to eq(1)
        end
        it 'contains Bob' do
          expect(clients_that_fit.ids).to include bob.id
        end
        it 'does not contain Roy' do
          expect(clients_that_fit.ids).to_not include roy.id
        end
      end

      context 'when negative' do
        it 'matches 1' do
          expect(clients_that_dont_fit.count).to eq(1)
        end
        it 'does not contain Bob' do
          expect(clients_that_dont_fit.ids).to_not include bob.id
        end
        it 'contains Roy' do
          expect(clients_that_dont_fit.ids).to include roy.id
        end
      end
    end
  end
end
