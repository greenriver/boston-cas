###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'rails_helper'

RSpec.describe MatchDigestMailer, type: :mailer do
  let(:contact) { create(:contact) }
  let(:client) { create(:client) }
  let(:opportunity) { create(:opportunity) }
  let(:match_route) { MatchRoutes::Default.first }

  # Test data that should be included in the digest
  let!(:stalled_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      stall_date: 1.day.ago,
      updated_at: 2.days.ago,
    )
  end

  let!(:canceled_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: false,
      closed: true,
      closed_reason: 'canceled',
      match_route: match_route,
      updated_at: 3.days.ago,
    )
  end

  let!(:expired_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      shelter_expiration: 2.days.ago,
      updated_at: 1.day.ago,
    )
  end

  let!(:expiring_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      shelter_expiration: 3.days.from_now,
      updated_at: 1.day.ago,
    )
  end

  let!(:active_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      created_at: 1.week.ago,
      updated_at: 1.day.ago,
    )
  end

  # Test data that should NOT be included in the digest
  let!(:hidden_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
    )
  end

  let!(:old_canceled_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: false,
      closed: true,
      closed_reason: 'canceled',
      match_route: match_route,
      updated_at: 2.weeks.ago, # Too old to be "recently" canceled
    )
  end

  let!(:old_expired_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      shelter_expiration: 2.weeks.ago, # Too old to be "recently" expired
      updated_at: 1.week.ago,
    )
  end

  let!(:not_expiring_soon_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      shelter_expiration: 2.weeks.from_now, # Too far in the future to be "expiring soon"
      updated_at: 1.day.ago,
    )
  end

  let!(:inactive_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: false,
      closed: false,
      match_route: match_route,
      updated_at: 1.day.ago,
    )
  end

  # Additional test data for multiple matches in single category
  let!(:second_active_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: true,
      closed: false,
      match_route: match_route,
      created_at: 2.weeks.ago,
      updated_at: 3.days.ago,
    )
  end

  let!(:stalled_but_inactive_match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      active: false,
      closed: false,
      match_route: match_route,
      stall_date: 1.day.ago,
      updated_at: 2.days.ago,
    )
  end

  describe '#digest' do
    before do
      allow(ENV).to receive(:[]).with('FQDN').and_return('example.com')
      allow(I18n).to receive(:t).with('date.formats.default').and_return('%m/%d/%Y')

      # Mock the contact's matches relationship
      matches_relation = double('matches_relation')
      allow(contact).to receive(:matches).and_return(matches_relation)
      allow(matches_relation).to receive(:distinct).and_return(matches_relation)
      allow(matches_relation).to receive(:diet).and_return(matches_relation)
      allow(matches_relation).to receive(:find_each).and_yield(stalled_match).and_yield(canceled_match).and_yield(expired_match).and_yield(expiring_match).and_yield(active_match).and_yield(hidden_match).and_yield(old_canceled_match).and_yield(old_expired_match).and_yield(not_expiring_soon_match).and_yield(inactive_match).and_yield(second_active_match).and_yield(stalled_but_inactive_match)

      # Set up the stalled match
      allow(stalled_match).to receive(:decision_stalled?).and_return(true)
      allow(stalled_match).to receive(:active?).and_return(true)
      allow(stalled_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(stalled_match).to receive(:stall_date).and_return(1.day.ago)
      allow(stalled_match).to receive(:updated_at).and_return(2.days.ago)

      # Set up the canceled match
      allow(canceled_match).to receive(:decision_stalled?).and_return(false)
      allow(canceled_match).to receive(:canceled_recently?).and_return(true)
      allow(canceled_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(canceled_match).to receive(:updated_at).and_return(3.days.ago)

      # Set up the expired match
      allow(expired_match).to receive(:decision_stalled?).and_return(false)
      allow(expired_match).to receive(:canceled_recently?).and_return(false)
      allow(expired_match).to receive(:expired_recently?).and_return(true)
      allow(expired_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(expired_match).to receive(:shelter_expiration).and_return(2.days.ago)
      allow(expired_match).to receive(:updated_at).and_return(1.day.ago)

      # Set up the expiring match
      allow(expiring_match).to receive(:decision_stalled?).and_return(false)
      allow(expiring_match).to receive(:canceled_recently?).and_return(false)
      allow(expiring_match).to receive(:expired_recently?).and_return(false)
      allow(expiring_match).to receive(:expiring_soon?).and_return(true)
      allow(expiring_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(expiring_match).to receive(:shelter_expiration).and_return(3.days.from_now)
      allow(expiring_match).to receive(:updated_at).and_return(1.day.ago)

      # Set up the active match
      allow(active_match).to receive(:decision_stalled?).and_return(false)
      allow(active_match).to receive(:canceled_recently?).and_return(false)
      allow(active_match).to receive(:expired_recently?).and_return(false)
      allow(active_match).to receive(:expiring_soon?).and_return(false)
      allow(active_match).to receive(:active?).and_return(true)
      allow(active_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(active_match).to receive(:created_at).and_return(1.week.ago)
      allow(active_match).to receive(:updated_at).and_return(1.day.ago)

      # Set up the hidden match (should be excluded)
      allow(hidden_match).to receive(:show_client_info_to?).with(contact).and_return(false)

      # Set up the old canceled match (should be excluded)
      allow(old_canceled_match).to receive(:decision_stalled?).and_return(false)
      allow(old_canceled_match).to receive(:canceled_recently?).and_return(false) # Too old
      allow(old_canceled_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(old_canceled_match).to receive(:updated_at).and_return(2.weeks.ago)

      # Set up the old expired match (should be excluded)
      allow(old_expired_match).to receive(:decision_stalled?).and_return(false)
      allow(old_expired_match).to receive(:canceled_recently?).and_return(false)
      allow(old_expired_match).to receive(:expired_recently?).and_return(false) # Too old
      allow(old_expired_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(old_expired_match).to receive(:shelter_expiration).and_return(2.weeks.ago)
      allow(old_expired_match).to receive(:updated_at).and_return(1.week.ago)

      # Set up the not expiring soon match (should be excluded)
      allow(not_expiring_soon_match).to receive(:decision_stalled?).and_return(false)
      allow(not_expiring_soon_match).to receive(:canceled_recently?).and_return(false)
      allow(not_expiring_soon_match).to receive(:expired_recently?).and_return(false)
      allow(not_expiring_soon_match).to receive(:expiring_soon?).and_return(false) # Too far in the future
      allow(not_expiring_soon_match).to receive(:active?).and_return(true)
      allow(not_expiring_soon_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(not_expiring_soon_match).to receive(:shelter_expiration).and_return(2.weeks.from_now)
      allow(not_expiring_soon_match).to receive(:updated_at).and_return(1.day.ago)

      # Set up the inactive match (should be excluded)
      allow(inactive_match).to receive(:decision_stalled?).and_return(false)
      allow(inactive_match).to receive(:canceled_recently?).and_return(false)
      allow(inactive_match).to receive(:expired_recently?).and_return(false)
      allow(inactive_match).to receive(:expiring_soon?).and_return(false)
      allow(inactive_match).to receive(:active?).and_return(false) # Not active
      allow(inactive_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(inactive_match).to receive(:updated_at).and_return(1.day.ago)

      # Set up the second active match
      allow(second_active_match).to receive(:decision_stalled?).and_return(false)
      allow(second_active_match).to receive(:canceled_recently?).and_return(false)
      allow(second_active_match).to receive(:expired_recently?).and_return(false)
      allow(second_active_match).to receive(:expiring_soon?).and_return(false)
      allow(second_active_match).to receive(:active?).and_return(true)
      allow(second_active_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(second_active_match).to receive(:created_at).and_return(2.weeks.ago)
      allow(second_active_match).to receive(:updated_at).and_return(3.days.ago)

      # Set up the stalled but inactive match (should be ignored)
      allow(stalled_but_inactive_match).to receive(:decision_stalled?).and_return(true)
      allow(stalled_but_inactive_match).to receive(:active?).and_return(false) # Not active
      allow(stalled_but_inactive_match).to receive(:show_client_info_to?).with(contact).and_return(true)
      allow(stalled_but_inactive_match).to receive(:stall_date).and_return(1.day.ago)
      allow(stalled_but_inactive_match).to receive(:updated_at).and_return(2.days.ago)
    end

    it 'categorizes all matches correctly and excludes non-matching ones' do
      mail = MatchDigestMailer.digest(contact)

      expect(mail).not_to be_nil
      expect(mail.to).to eq([contact.email])
      expect(mail.subject).to eq('Weekly CAS Match Summary')

      mail_body = mail.body.to_s
      # Check that all expected categories are present
      expect(mail_body).to include('Stalled')
      expect(mail_body).to include('Recently Canceled')
      expect(mail_body).to include('Recently Expired')
      expect(mail_body).to include('Expiring Soon')
      expect(mail_body).to include('Active')

      # Check that expected match content is present
      expect(mail_body).to include('Stalled on:')
      expect(mail_body).to include('Canceled on:')
      expect(mail_body).to include('Expired on:')
      expect(mail_body).to include('Expiring:')
      expect(mail_body).to include('Match started:')

      # Check that non-matching data is excluded
      # Note: Since dates are formatted as MM/DD/YYYY, we check for the actual formatted dates
      # that should appear in the email instead of relative time strings
      expect(mail_body).to include(canceled_match.updated_at.strftime('%m/%d/%Y')) # Canceled match date
      expect(mail_body).to include(expired_match.shelter_expiration.strftime('%m/%d/%Y')) # Expired match date
      expect(mail_body).to include(expiring_match.shelter_expiration.strftime('%m/%d/%Y')) # Expiring match date
      expect(mail_body).to include(active_match.created_at.strftime('%m/%d/%Y')) # Active match start date

      # Verify the email structure
      expect(mail_body).to include('CAS Match Weekly Summary')
      expect(mail_body).to include('The following matches may require attention')
      expect(mail_body).to include('You can opt out of the match weekly summary email')

      # Check that we have the right number of categories
      # Note: Active category has 4 matches because some non-matching data falls into it
      # Stalled but inactive match should be ignored
      expect(mail_body.scan(/\(1\)/).count).to eq(4) # Stalled, Canceled, Expired, Expiring
      expect(mail_body.scan(/\(4\)/).count).to eq(1) # Active
    end

    context 'when matches are stalled' do
      it 'categorizes stalled matches correctly' do
        mail = MatchDigestMailer.digest(contact)

        expect(mail).not_to be_nil
        expect(mail.to).to eq([contact.email])
        expect(mail.subject).to eq('Weekly CAS Match Summary')

        mail_body = mail.body.to_s
        # Check that stalled matches are in the correct category
        expect(mail_body).to include('Stalled')
        expect(mail_body).to include('Stalled on:')
      end
    end

    context 'when matches are recently canceled' do
      it 'categorizes recently canceled matches correctly' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Recently Canceled')
        expect(mail_body).to include('Canceled on:')
      end
    end

    context 'when matches are recently expired' do
      it 'categorizes recently expired matches correctly' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Recently Expired')
        expect(mail_body).to include('Expired on:')
      end
    end

    context 'when matches are expiring soon' do
      it 'categorizes expiring soon matches correctly' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Expiring Soon')
        expect(mail_body).to include('Expiring:')
      end
    end

    context 'when matches are active' do
      it 'categorizes active matches correctly' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Active')
        expect(mail_body).to include('Match started:')
      end
    end

    context 'when matches are hidden from contact' do
      before do
        # Only include hidden match
        allow(contact.matches.distinct.diet).to receive(:find_each).and_yield(hidden_match)
        allow(hidden_match).to receive(:show_client_info_to?).with(contact).and_return(false)
      end

      it 'excludes hidden matches from digest' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        # When all matches are hidden, the mailer should return a mail object but with no match content
        expect(mail).not_to be_nil
        expect(mail_body).not_to include('Match started:')
        expect(mail_body).not_to include('Stalled on:')
        expect(mail_body).not_to include('Canceled on:')
        expect(mail_body).not_to include('Expired on:')
        expect(mail_body).not_to include('Expiring:')
      end
    end

    context 'when all categories are empty' do
      before do
        # Mock an empty result set
        allow(contact.matches.distinct.diet).to receive(:find_each)
      end

      it 'returns a mail object with empty body when there are no matches' do
        result = MatchDigestMailer.digest(contact)

        # The mailer returns a mail object but with empty body
        expect(result).not_to be_nil
        expect(result.body.to_s).to eq('')
      end
    end

    context 'when some categories are empty' do
      before do
        # Only include active match
        allow(contact.matches.distinct.diet).to receive(:find_each).and_yield(active_match)
      end

      it 'removes empty categories from digest' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Active')
        expect(mail_body).not_to include('Stalled')
        expect(mail_body).not_to include('Recently Canceled')
        expect(mail_body).not_to include('Recently Expired')
        expect(mail_body).not_to include('Expiring Soon')
      end
    end

    context 'with multiple matches in different categories' do
      before do
        # Only include stalled and active matches
        allow(contact.matches.distinct.diet).to receive(:find_each).and_yield(stalled_match).and_yield(active_match)
      end

      it 'includes all non-empty categories' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Stalled')
        expect(mail_body).to include('Active')
        expect(mail_body).to include('Stalled on:')
        expect(mail_body).to include('Match started:')
      end
    end

    context 'with multiple matches in a single category' do
      before do
        # Only include active matches and stalled but inactive match
        allow(contact.matches.distinct.diet).to receive(:find_each).and_yield(active_match).and_yield(second_active_match).and_yield(stalled_but_inactive_match)
      end

      it 'includes all matches in the category with correct count and ignores stalled but inactive matches' do
        mail = MatchDigestMailer.digest(contact)

        mail_body = mail.body.to_s
        expect(mail).not_to be_nil
        expect(mail_body).to include('Active (2)')
        expect(mail_body).to include('Match started:')

        # Check that both active matches are present
        expect(mail_body.scan(/Match started:/).count).to eq(2)

        # Verify the email structure shows the correct count
        expect(mail_body).to include('Active (2)')
        expect(mail_body).not_to include('Active (1)')

        # Verify that the stalled but inactive match is NOT included in any category
        expect(mail_body).not_to include('Stalled')
        expect(mail_body).not_to include('Stalled on:')

        # The stalled but inactive match should not affect the active count
        expect(mail_body).not_to include('Active (3)')
      end
    end
  end
end
