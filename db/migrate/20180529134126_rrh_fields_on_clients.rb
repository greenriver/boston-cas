class RrhFieldsOnClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :ssvf_eligible, :boolean, null: false, default: false
    add_column :project_clients, :rrh_desired, :boolean, null: false, default: false
    add_column :project_clients, :youth_rrh_desired, :boolean, null: false, default: false
    add_column :project_clients, :rrh_assessment_contact_info, :string
    add_column :project_clients, :rrh_assessment_collected_at, :datetime
    add_column :project_clients, :enrolled_in_th, :boolean, default: false, null: false
    add_column :project_clients, :enrolled_in_es, :boolean, default: false, null: false
    add_column :project_clients, :enrolled_in_sh, :boolean, default: false, null: false
    add_column :project_clients, :enrolled_in_so, :boolean, default: false, null: false

    add_column :clients, :ssvf_eligible, :boolean, null: false, default: false
    add_column :clients, :rrh_desired, :boolean, null: false, default: false
    add_column :clients, :youth_rrh_desired, :boolean, null: false, default: false
    add_column :clients, :rrh_assessment_contact_info, :string
    add_column :clients, :rrh_assessment_collected_at, :datetime
    add_column :clients, :enrolled_in_th, :boolean, default: false, null: false
    add_column :clients, :enrolled_in_es, :boolean, default: false, null: false
    add_column :clients, :enrolled_in_sh, :boolean, default: false, null: false
    add_column :clients, :enrolled_in_so, :boolean, default: false, null: false

  end
end
