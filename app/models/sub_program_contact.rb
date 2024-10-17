###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SubProgramContact < ApplicationRecord
  belongs_to :sub_program, inverse_of: :sub_program_contacts
  belongs_to :contact, inverse_of: :sub_program_contacts

  def self.contact_types
    [
      :shelter_agency,
      :client,
      :dnd_staff,
      :housing_subsidy_admin,
      :ssp,
      :hsp,
      :do,
    ].freeze
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
