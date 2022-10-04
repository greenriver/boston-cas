###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module ClientOpportunityMatches
  module HasDecisions
    # Individual decision and notification points in the lifecycle of a match
    # are represented as their own objects.  See MatchDecisions::Base and its
    # subclasses.

    # This module makes those decision objects accessible to the match
    # For example, calling `has_decision :example` will do the following:
    #
    # 1.  define a `has_one example_decision` association which returns a `MatchDecisions::Example`
    # 2.  create this associated record when the match is created
    # 3.  define a `has_many example_notifications` association which returns records of type `Notifications::Example`
    extend ActiveSupport::Concern

    included do
      # this class variable is used by #decisions
      # to initialize the appropriate classes
      @@decision_types = [] # rubocop:disable Style/ClassVars

      has_many :decisions,
               class_name: 'MatchDecisions::Base',
               foreign_key: 'match_id',
               inverse_of: :match,
               dependent: :destroy

      has_many :initialized_decisions,
               -> { where.not(status: nil) },
               class_name: 'MatchDecisions::Base',
               foreign_key: 'match_id',
               inverse_of: :match,
               dependent: :destroy

      # macro to set up a decision within a match
      def self.has_decision(decision_type, decision_class_name: nil, notification_class_name: nil) # rubocop:disable Naming/PredicateName
        decision_class_name ||= "MatchDecisions::#{decision_type.to_s.camelize}"
        notification_class_name ||= "Notifications::#{decision_type.to_s.camelize}"
        # define the decision_contact association
        # e.g. match_recommendation_dnd_staff_contact
        has_one "#{decision_type}_decision".to_sym,
                class_name: decision_class_name,
                foreign_key: :match_id,
                inverse_of: :match

        has_many "#{decision_type}_notifications".to_sym,
                 class_name: notification_class_name,
                 foreign_key: :client_opportunity_match_id,
                 inverse_of: :match

        @@decision_types << decision_type
      end

      # FIXME: This should create decisions in the order for the route (maybe also only create the decisions that should be on the route)
      after_create :create_decisions!
    end

    def decision_from_param param
      send "#{param}_decision" if param.to_sym.in? @@decision_types
    end

    private

    def create_decisions!
      @@decision_types.each do |decision_type|
        send("create_#{decision_type}_decision!")
      end
    end

    def decisions_for_events
      initialized_decisions
        .preload(:contact).to_a
    end
  end
end
