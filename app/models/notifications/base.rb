###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class Base < ApplicationRecord
    self.table_name = 'notifications'

    has_paper_trail

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self, nil, 'notification') # rubocop:disable Naming/MemoizedInstanceVariableName
    end

    belongs_to :match, class_name: 'ClientOpportunityMatch', foreign_key: 'client_opportunity_match_id'

    belongs_to :recipient, class_name: 'Contact'
    delegate :name, to: :recipient, allow_nil: true, prefix: true
    has_many :notification_delivery_events, class_name: 'MatchEvents::NotificationDelivery', foreign_key: :notification_id

    attribute :decision_id_for_delivery, :integer

    validates :code, uniqueness: true

    before_validation :setup_code
    after_create :deliver

    def setup_code
      self.code ||= SecureRandom.urlsafe_base64
    end

    def to_param
      code
    end

    def deliver
      return unless match.match_route.send_notifications

      DeliverJob.perform_later(self, decision_id_for_delivery)
    end

    class DeliverJob < ActiveJob::Base
      def perform(notification, decision_id = nil)
        NotificationsMailer.send(notification.notification_type, notification).deliver_now
        notification.record_delivery_event!(decision_id: decision_id)
      end
    end
    private_constant :DeliverJob

    def to_partial_path
      "notifications/#{notification_type}"
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      self.class.to_s.demodulize.underscore
    end

    def decision
      notification_delivery_events.last&.decision
    end

    def event_label
      # how should this notification be dislayed when shown in an event timeline?
      raise 'abstract method not implemented'
    end

    def record_delivery_event!(decision_id: nil)
      decision_id_to_use = decision_id || decision&.id
      notification_delivery_events.create!(match: match, contact: recipient, decision_id: decision_id_to_use)
    end

    def contacts_editable?
      false
    end

    def self.create_for_match!(match, decision_id: nil)
      notification_recipients_for(match).each do |contact|
        next unless contact.notification_recipient?

        create!(match: match, recipient: contact, decision_id_for_delivery: decision_id)
      end
    end

    def self.recreate_for_match! match, contact
      return unless contact.notification_recipient?

      create! match: match, recipient: contact
    end

    # Override in subclasses to specify which contact types receive this notification
    # Example: [:shelter_agency_contacts, :dnd_staff_contacts]
    def self.contact_types_for_notification
      []
    end

    # Override in subclasses whose recipient set can't be expressed as a plain
    # list of contact_types_for_notification associations (e.g. exclusions).
    def self.notification_recipients_for(match)
      contact_types_for_notification.flat_map { |contact_type| match.send(contact_type) }
    end

    # Used by views to display which contact types receive notifications
    def self.contact_types_for_this_notification
      contact_types_for_notification
    end

    def expired?
      expires_at.in_time_zone <= Time.current.in_time_zone
    end

    # override in base class
    def allows_registration?
      false
    end

    def registration_role
      nil
    end
  end
end
