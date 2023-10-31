###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchDigestMailer < ApplicationMailer
  def digest(contact)
    @matches = [
      ['Stalled', :stalled],
      ['Recently Canceled', :canceled],
      ['Recently Expired', :expired],
      ['Expiring Soon', :expiring],
      ['Active', :active],
    ].each_with_object({}) do |group, hash|
      hash[group[1]] = { title: group[0], matches: [] }
    end
    contact.matches.distinct.diet.find_each do |match|
      next unless match.show_client_info_to?(contact)

      match_data = { path: match_url(match) }
      if match.decision_stalled?
        @matches[:stalled][:matches] << match_data.
          merge(text: "Stalled: #{match.stall_date.try(:strftime, I18n.t('date.formats.default')) || 'unknown'}")
      elsif match.canceled_recently?
        @matches[:canceled][:matches] << match_data.
          merge(text: "Canceled: #{match.updated_at.strftime(I18n.t('date.formats.default')) || 'unknown'}")
      elsif match.expired_recently?
        @matches[:expired][:matches] << match_data.
          merge(text: "Expired: #{match.shelter_expiration.strftime(I18n.t('date.formats.default')) || 'unknown'}")
      elsif match.expiring_soon?
        @matches[:expiring][:matches] << match_data.
          merge(text: "Expiring: #{match.shelter_expiration.strftime(I18n.t('date.formats.default')) || 'unknown'}")
      elsif match.active?
        matched_on = match.created_at.strftime(I18n.t('date.formats.default'))
        updated_at = match.updated_at.strftime(I18n.t('date.formats.default'))
        @matches[:active][:matches] << match_data.
          merge(text: "Active: #{matched_on} - #{updated_at}")
      end
    end
    mail to: contact.email, subject: 'Match Digest'
  end
end
