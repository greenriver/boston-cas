class AddImportedNonHmisClientFields < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :imported_timestamp, :datetime
    # screener email to ensure applicant has a contact manager - ignored
    # signature 1 - ignored
    add_column :non_hmis_clients, :set_asides_housing_status, :string # a = literally homeless, b = shelter, c = institution
    add_column :non_hmis_clients, :set_asides_resident, :boolean
    # days_homeless_in_the_last_three_years
    # interested_in_set_asides (signature 2)
    add_column :non_hmis_clients, :shelter_name, :string
    add_column :non_hmis_clients, :entry_date, :date
    add_column :non_hmis_clients, :case_manager_contact_info, :string
    # rrh_assessment_contact_info
    # signature 3 - ignored
    # first_name
    # last_name
    add_column :non_hmis_clients, :phone_number, :string
    add_column :non_hmis_clients, :email, :string
    # income_total_monthly - form is by year so /12
    add_column :non_hmis_clients, :have_tenant_voucher, :boolean
    # agency
    add_column :non_hmis_clients, :children_info, :string
    add_column :non_hmis_clients, :studio_ok, :boolean
    add_column :non_hmis_clients, :one_br_ok, :boolean
    add_column :non_hmis_clients, :sro_ok, :boolean
    # studio_ok
    # required_number_of_bedrooms
    # requires_wheelchair_accessibility, requires_elevator_access
    # disabling_condition
    add_column :non_hmis_clients, :fifty_five_plus, :boolean
    add_column :non_hmis_clients, :sixty_two_plus, :boolean
    # neighborhood interests

    add_column :non_hmis_clients, :warehouse_client_id, :integer
    # available
  end
end
