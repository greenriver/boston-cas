###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class StalledResponse < ApplicationRecord
  include ActionView::Helpers
  include ActionView::Context

  scope :ordered, -> do
    order(weight: :asc, reason: :asc)
  end

  scope :active, -> do
    where(active: true)
  end

  scope :engaging, -> do
    where(client_engaging: true)
  end

  scope :not_engaging, -> do
    where(client_engaging: false)
  end

  scope :requiring_note, -> do
    where(requires_note: true)
  end

  scope :for_decision, ->(decision_type) do
    where(decision_type: decision_type)
  end

  def format_for_checkboxes
    if requires_note
      label = content_tag(:span) do
        concat(reason)
        concat(content_tag(:i, class: 'ml-2 icon-info', data: { toggle: :tooltip, title: 'Requires a note' }) { '' })
      end
    else
      label = reason
    end
    [
      label,
      reason,
    ]
  end

  def self.ensure_all
    all_responses.each do |response|
      response[:steps].each do |decision_type|
        attributes = response.except(:steps).merge(decision_type: decision_type)
        where(attributes).first_or_create
      end
    end
  end

  def self.all_responses
    [
      {
        client_engaging: true,
        reason: 'CORI Mitigation - Non-CoC resources only',
        steps: [
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
        ], # 4, 5
        requires_note: true,
      },
      {
        client_engaging: true,
        reason: 'HSA awaiting paperwork - Non-CoC resources only',
        steps: [
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin', # 3
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin', # 4
          'MatchDecisions::Four::MatchRecommendationHsa', # 4
        ],
        requires_note: true,
      },
      {
        client_engaging: true,
        reason: 'CORI hearing scheduled, awaiting date - Non-CoC resources only', # 4
        steps: [
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
        ],
        requires_note: true,
      },
      {
        client_engaging: true,
        reason: 'Client has submitted a Request for Tenancy - Mobile voucher only',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 5
        requires_note: false,
      },
      {
        client_engaging: true,
        reason: 'Client is waiting for unit to become available - Project or sponsor based unit only',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 5
        requires_note: false,
      },
      {
        client_engaging: true,
        reason: 'Client has submitted a Reasonable Accommodation',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 5
        requires_note: true,
      },
      {
        client_engaging: true,
        reason: 'Client is frequently engaging in housing search - Mobile voucher only',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 5
        requires_note: true,
      },
      {
        client_engaging: true,
        reason: 'Client is infrequently engaging in housing search - Mobile voucher only',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 5
        requires_note: true,
      },
      {
        client_engaging: true,
        reason: 'Other',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::Four::MatchRecommendationHsa',
        ], # 3,4,5,4
        requires_note: true,
        weight: 100,
      },
      {
        client_engaging: false,
        reason: 'Client refusing stabilization services',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: true,
      },
      {
        client_engaging: false,
        reason: 'Client refusing housing',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: true,
      },
      {
        client_engaging: false,
        reason: 'Client refusing housing and stabilization services',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: true,
      },
      {
        client_engaging: false,
        reason: 'Client refusing housing search services',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: true,
      },
      {
        client_engaging: false,
        reason: 'Client disappeared',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: false,
      },
      {
        client_engaging: false,
        reason: 'Client incarcerated',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: false,
      },
      {
        client_engaging: false,
        reason: 'Client in medical institution',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: false,
      },
      {
        client_engaging: false,
        reason: 'Shelter agency contact unable to contact client',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: true,
      },
      {
        client_engaging: false,
        reason: 'Other',
        steps: [
          'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator',
          'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin',
          'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin',
          'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator',
        ], # 3,4,5,4
        requires_note: true,
        weight: 100,
      },
    ]
  end
end
