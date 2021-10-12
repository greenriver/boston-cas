require 'rails_helper'

RSpec.describe DeidentifiedPathwaysVersionThree, type: :model do
  let(:lock_days) { 10 }
  let(:lock_grace_days) { 5 }
  let!(:config) { create :config, lock_days: lock_days, lock_grace_days: lock_grace_days, deidentified_client_assessment: 'DeidentifiedPathwaysVersionThree' }
  let(:user) { create :user }
  let(:client) { create :deidentified_client }

  it 'does not add locked_until when calling lock on a new transfer assessment' do
    assessment = client.assessment_type.constantize.new(
      agency_id: user.agency_id,
      non_hmis_client_id: client.id,
      assessment_type: :transfer_assessment,
    )
    expect(assessment.locked_until).to be_blank
    assessment.lock
    expect(assessment.locked_until).to be_blank
  end

  it 'adds locked_until when calling lock on a new assessment' do
    assessment = client.assessment_type.constantize.new(
      agency_id: user.agency_id,
      non_hmis_client_id: client.id,
      assessment_type: :pathways_2021,
    )
    expect(assessment.locked_until).to be_blank
    assessment.lock
    expect(assessment.locked_until).not_to be_blank
    expect(assessment.locked_until).to eq Date.current + lock_days
  end

  it 'not locked during grace period, locked after, unlocked post lock date' do
    assessment = client.assessment_type.constantize.new(
      agency_id: user.agency_id,
      non_hmis_client_id: client.id,
      assessment_type: :pathways_2021,
    )
    assessment.lock
    expect(assessment.locked?).to be false
    Timecop.travel(Time.current + (lock_grace_days - 1).days) do
      expect(assessment.locked?).to be false
      expect(assessment.in_lock_grace_period?).to be true
    end
    Timecop.travel(Time.current + lock_grace_days.days) do
      expect(assessment.locked?).to be true
      expect(assessment.in_lock_grace_period?).to be false
    end
    Timecop.travel(Time.current + (lock_days - 1).days) do
      expect(assessment.locked?).to be true
      expect(assessment.in_lock_grace_period?).to be false
    end
    Timecop.travel(Time.current + lock_days.days) do
      expect(assessment.locked?).to be false
      expect(assessment.in_lock_grace_period?).to be false
    end
  end
end
