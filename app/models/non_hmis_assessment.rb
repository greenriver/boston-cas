###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class NonHmisAssessment < ActiveRecord::Base
  include ApplicationHelper

  has_paper_trail
  acts_as_paranoid

  attr_accessor :youth_rrh_aggregate, :dv_rrh_aggregate, :total_days_homeless_in_the_last_three_years

  belongs_to :non_hmis_client
  belongs_to :user

  after_find :populate_aggregates

  before_save :update_assessment_score

  def title
    'Non-HMIS Assessment'
  end

  def update_assessment_score!
    update_assessment_score()
    save()
    non_hmis_client.save()
  end

  def total_days_homeless_in_the_last_three_years
    (days_homeless_in_the_last_three_years || 0) + (additional_homeless_nights || 0)
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

  def self.form_field_labels
    return [] unless self.respond_to?(:form_fields)

    [].tap do |labels|
      form_fields.map do |_, field|
        # If there are sub-questions, there will not be answers at this level
        if ! field[:questions]
          labels << field[:label]
        else
          field[:questions].each do |_, f|
            labels << f[:label]
          end
        end
      end
    end
  end

  def form_field_values
    return [] unless self.class.respond_to?(:form_fields)

    [].tap do |values|
      self.class.form_fields.map do |name, field|
        # If there are sub-questions, there will not be answers at this level
        if ! field[:questions]
          val = send(name)
          values << if val.is_a?(Array)
            field[:collection].invert.values_at(*val).to_sentence
          elsif val.in?([true, false])
            yes_no(val)
          else
            val
          end
        else
          field[:questions].each do |sub_name, f|
            val = send(sub_name)
            values << if val.is_a?(Array)
              val = val.select(&:present?)
              next unless val.present?

              f[:collection].invert.values_at(*val).to_sentence
            elsif val.in?([true, false])
              yes_no(val)
            else
              val
            end
          end
        end
      end
    end
  end
end
