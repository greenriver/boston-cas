class AddClientBoxesToMatchDecisions < ActiveRecord::Migration
  def change
    add_column :match_decisions, :client_spoken_with_services_agency, :boolean, default: false
    add_column :match_decisions, :cori_release_form_submitted, :boolean, default: false
  end
end
