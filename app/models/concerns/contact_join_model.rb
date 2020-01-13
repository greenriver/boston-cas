###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module ContactJoinModel
  # Mixin designed for contact join models (e.g. ClientContact)
  # to get them to work with uniform interface code

  # N.B.  be sure to include this module after the contact
  # association has been defined

  extend ActiveSupport::Concern

  included do
    delegate :full_name, :email, :phone, :role,
    to: :contact, allow_nil: true, prefix: true

    accepts_nested_attributes_for :contact

    def self.model_name
      # really just needed for route_key
      # keeps standard naming but uses 'contact' for routes
      @_model_name ||= ActiveModel::Name.new(self, nil, to_s.demodulize.underscore).tap do |model_name|
        model_name.instance_variable_set(:@route_key, 'contacts')
        model_name.instance_variable_set(:@singular_route_key, 'contact')
      end
    end
  end
end