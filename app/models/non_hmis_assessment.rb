###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class NonHmisAssessment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  attr_accessor :youth_rrh_aggregate, :dv_rrh_aggregate

  belongs_to :non_hmis_client
  belongs_to :user

  after_find :populate_aggregates

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
end