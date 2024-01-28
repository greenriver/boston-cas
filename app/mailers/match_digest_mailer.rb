###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchDigestMailer < DatabaseMailer
  def digest(contact)
    @matches = {
      stalled: {
        title: 'Stalled',
        matches: [],
      },
      canceled: {
        title: 'Recently Canceled',
        matches: [],
      },
      expired: {
        title: 'Recently Expired',
        matches: [],
      },
      expiring: {
        title: 'Expiring Soon',
        matches: [],
      },
      active: {
        title: 'Active',
        matches: [],
      },
    }
    contact.matches.distinct.diet.find_each do |match|
      next unless match.show_client_info_to?(contact)

      # Unclear why host isn't correctly set as it is for other mailers
      match_data = { path: match_url(match, host: ENV['FQDN']) }
      updated_at = match.updated_at.strftime(I18n.t('date.formats.default'))
      if match.decision_stalled?
        @matches[:stalled][:matches] << match_data.
          merge(text: "Stalled on: #{match.stall_date.try(:strftime, I18n.t('date.formats.default')) || 'unknown'}, last updated: #{updated_at}")
      elsif match.canceled_recently?
        @matches[:canceled][:matches] << match_data.
          merge(text: "Canceled on: #{match.updated_at.strftime(I18n.t('date.formats.default')) || 'unknown'}, last updated: #{updated_at}")
      elsif match.expired_recently?
        @matches[:expired][:matches] << match_data.
          merge(text: "Expired on: #{match.shelter_expiration.strftime(I18n.t('date.formats.default')) || 'unknown'}, last updated: #{updated_at}")
      elsif match.expiring_soon?
        @matches[:expiring][:matches] << match_data.
          merge(text: "Expiring: #{match.shelter_expiration.strftime(I18n.t('date.formats.default')) || 'unknown'}, last updated: #{updated_at}")
      elsif match.active?
        matched_on = match.created_at.strftime(I18n.t('date.formats.default'))
        @matches[:active][:matches] << match_data.
          merge(text: "Match started: #{matched_on}, last updated: #{updated_at}")
      end
    end
    @matches.each do |k, v|
      @matches.delete(k) if v[:matches].empty?
    end
    return if @matches.values.flat_map { |v| v[:matches] }.empty?

    mail to: contact.email, subject: 'Weekly CAS Match Summary'
  end
end
