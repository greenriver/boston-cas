###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientContact < ApplicationRecord
  belongs_to :client, inverse_of: :client_contacts
  belongs_to :contact, inverse_of: :client_contacts

  acts_as_paranoid
  has_paper_trail

  def self.contact_types
    [
      :regular,
      :shelter_agency,
      :dnd_staff,
      :housing_subsidy_admin,
      :ssp,
      :hsp,
      :do,
    ].freeze
  end

  def self.contact_type_columns
    contact_types.map { |t| ["#{t}_contacts".to_sym, t] }.to_h
  end

  def self.available_contact_methods
    contact_types.map { |t| ["#{t}_contacts".to_sym, "available_#{t}_contacts".to_sym] }.to_h
  end

  def self.available_contact_method_for(contact_type)
    available_contact_methods[contact_type] || contact_type
  end

  def self.selected_contact_methods
    contact_types.map { |t| ["#{t}_contacts".to_sym, "#{t}_contacts".to_sym] }.to_h
  end

  def self.selected_contact_method_for(contact_type)
    selected_contact_methods[contact_type] || contact_type
  end
end
