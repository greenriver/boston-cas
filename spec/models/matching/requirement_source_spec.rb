require 'rails_helper'
include ActiveJob::TestHelper

# NOTE: requirements can be added at any of the following levels:
# (This can be found by investigating inherited_requirements_by_source in InheritsRequirementsFromServicesOnly or the classes)
# Funding Source (inline, service)
# Sub-Grantee (inline, service)
# Program (inline, service, funding source)
# Sub-program (program, service_provider, sub_contractor, building)
# Service
# Building (inline, service)
# Unit (inline, service)
# Voucher
RSpec.describe Matching::Engine, type: :model do
  CasSeeds::Rules.new.run!
  CasSeeds::Services.new.run!
  let!(:priority) { create :priority_vispdat_priority }
  let!(:route) { create :default_route, match_prioritization: priority }
  let!(:veteran) { create :client, veteran: true }
  let!(:non_veteran) { create :client, veteran: false }

  let!(:funding_source) { create :funding_source }
  let!(:building) { create :building }
  let!(:sub_grantee) { create :subgrantee }
  let!(:program) { create :program, match_route_id: route.id, funding_source: funding_source }
  let!(:sub_program) { create :sub_program, program: program, service_provider: sub_grantee }
  let!(:unit) { create :unit, building: building }
  let!(:voucher) { create :voucher, sub_program: sub_program }
  let!(:opportunity) { create :opportunity, voucher: voucher }
  let(:requirements) { [Requirement.new(rule: Rules::Veteran.first, positive: true)] }

  describe 'requirement on program' do
    before(:each) do
      program.update(requirements: requirements)
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end

  describe 'requirement on service' do
    before(:each) do
      service = Service.first
      service.update(requirements: requirements)
      program.update(services: [service])
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end

  describe 'requirement on building' do
    before(:each) do
      building.update(requirements: requirements)
      voucher.update(unit: unit)
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end

  describe 'requirement on funding source' do
    before(:each) do
      funding_source.update(requirements: requirements)
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end

  describe 'requirement on sub-grantee' do
    before(:each) do
      sub_grantee.update(requirements: requirements)
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end

  describe 'requirement on unit' do
    before(:each) do
      unit.update(requirements: requirements)
      voucher.update(unit: unit)
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end

  describe 'requirement on voucher' do
    before(:each) do
      voucher.update(requirements: requirements)
    end
    it 'veteran matches opportunity' do
      expect(opportunity.matches_client?(veteran)).to be(true)
    end
    it 'non-veteran does not match opportunity' do
      expect(opportunity.matches_client?(non_veteran)).to be(false)
    end
  end
end
