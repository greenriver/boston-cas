###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class NonHmisAssessment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  attr_accessor :youth_rrh_aggregate, :dv_rrh_aggregate

  belongs_to :non_hmis_client
  belongs_to :user

  after_find :populate_aggregates

  before_save :update_assessment_score

  def update_assessment_score!
    update_assessment_score()
    save()
    non_hmis_client.save()
  end

  private def update_assessment_score
    if respond_to? :calculated_score
      self.assessment_score = calculated_score
    end
    if self.non_hmis_client
      self.non_hmis_client.assign_attributes(
        assessment_score: self.assessment_score,
        assessed_at: self.updated_at || Time.current,
      )
    end
  end

  private def populate_aggregates
    if youth_rrh_desired? && rrh_desired?
      self.youth_rrh_aggregate = 'both'
    elsif youth_rrh_desired?
      self.youth_rrh_aggregate = 'youth'
    elsif rrh_desired?
      self.youth_rrh_aggregate = 'adult'
    end

    if dv_rrh_desired? && rrh_desired?
      self.dv_rrh_aggregate = 'both'
    elsif dv_rrh_desired?
      self.dv_rrh_aggregate = 'dv'
    elsif rrh_desired?
      self.dv_rrh_aggregate = 'non-dv'
    end
  end

  def default?
    true
  end

end
