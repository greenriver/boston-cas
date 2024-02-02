###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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
      DeliverJob.perform_later(self) if match.match_route.send_notifications
    end

    class DeliverJob < ActiveJob::Base
      def perform(notification)
        NotificationsMailer.send(notification.notification_type, notification).deliver_now
        notification.record_delivery_event!
      end
    end
    private_constant :DeliverJob

    def to_partial_path
      "notifications/#{self.class.to_s.demodulize.underscore}"
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      self.class.to_s.demodulize.underscore
    end

    def decision
      nil
    end

    def event_label
      # how should this notification be dislayed when shown in an event timeline?
      raise 'abstract method not implemented'
    end

    def record_delivery_event!
      notification_delivery_events.create! match: match, contact: recipient
    end

    def contacts_editable?
      false
    end

    def self.recreate_for_match! match, contact
      create! match: match, recipient: contact
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
