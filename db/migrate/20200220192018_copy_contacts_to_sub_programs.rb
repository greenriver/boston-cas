class CopyContactsToSubPrograms < ActiveRecord::Migration[6.0]
  ATTRIBUTES = [
    :contact,
    :deleted_at,
    :dnd_staff,
    :housing_subsidy_admin,
    :client,
    :housing_search_worker,
    :shelter_agency,
    :ssp,
    :hsp,
    :do,
  ]
  def change
    Program.find_each do |program|
      program.sub_programs.find_each do |sub_program|
        program.program_contacts.each do |contact|
          sub_program.sub_program_contacts.create(contact.slice(ATTRIBUTES))
        end
      end
    end
  end
end
