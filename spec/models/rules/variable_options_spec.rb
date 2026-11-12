###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rule#variable_options', type: :model do
  # Rules are discovered from disk because test eager loading is off outside CI.
  rule_classes = Dir[Rails.root.join('app/models/rules/*.rb')].
    map { |path| "Rules::#{File.basename(path, '.rb').camelize}".safe_constantize }.
    select { |klass| klass.is_a?(Class) && klass < Rule }.
    select { |klass| klass.new.then { |r| r.variable_requirement? && r.variable_input_type.in?(['select', 'multi-select']) } }

  def option_pairs(rule)
    JSON.parse(rule.variable_options.to_json)
  end

  # CI has no warehouse tables. stub_const keeps the models out of play entirely:
  # any allow(...) on an ActiveRecord class makes rspec-rails load its columns.
  def stub_warehouse_queries
    allow(Warehouse::Base).to receive(:enabled?).and_return(true)
    stub_const('Warehouse::Tag', double(pluck: ['Veteran']))
    stub_const('Warehouse::Cohort', double(visible_in_cas: double(active: double(pluck: [[1, 'Cohort', nil]]))))
    project = double(id: 1, ProjectName: 'Project', organization: double(OrganizationName: 'Org'))
    stub_const('Warehouse::Project', double(joins: double(preload: [project])))
  end

  it 'discovers the select-type rules, including those backed by the database' do
    expect(rule_classes).to include(
      Rules::RankBelow,
      Rules::NonHmisAssessmentType,
      Rules::HasFileTags,
      Rules::ActiveInCohort,
      Rules::EnrolledInHmisProject,
      Rules::InterestedInNeighborhood,
      Rules::TaggedWith,
    )
  end

  context 'with a record behind each database-backed rule' do
    before do
      create(:neighborhood_cambridge)
      create(:tag)
      stub_warehouse_queries
    end

    rule_classes.each do |klass|
      it "#{klass.name} serializes its options as a non-empty array of [value, label] pairs" do
        parsed = option_pairs(klass.new)
        expect(parsed).to be_an(Array)
        expect(parsed).not_to be_empty
        expect(parsed).to all(match([anything, anything]))
      end
    end
  end

  it 'RankBelow offers ranks 1 through 500 labeled by number' do
    parsed = option_pairs(Rules::RankBelow.new)
    expect(parsed).to be_an(Array)
    expect(parsed.first).to eq([1, 1])
    expect(parsed.last).to eq([500, 500])
    expect(parsed.size).to eq(500)
  end

  it 'NonHmisAssessmentType offers assessment class names labeled for display' do
    expect(option_pairs(Rules::NonHmisAssessmentType.new)).
      to include(['IdentifiedClientAssessment', 'Non-HMIS Assessment - Identified'])
  end

  it 'NonHmisAssessmentType still displays labels for a stored comma-separated value' do
    rule = Rules::NonHmisAssessmentType.new
    expect(rule.display_for_variable('IdentifiedClientAssessment,DeidentifiedClientAssessment')).
      to eq('Non-HMIS Assessment - Identified or Non-HMIS Assessment - Deidentified')
  end

  it 'HasFileTags offers warehouse tag names as both value and label' do
    stub_warehouse_queries

    parsed = option_pairs(Rules::HasFileTags.new)
    expect(parsed).to be_an(Array)
    expect(parsed).to contain_exactly(['Veteran', 'Veteran'])
  end
end
