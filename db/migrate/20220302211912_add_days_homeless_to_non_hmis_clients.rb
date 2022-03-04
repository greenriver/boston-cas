class AddDaysHomelessToNonHmisClients < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :days_homeless, :integer
    add_column :non_hmis_clients, :sixty_plus, :boolean
    add_column :non_hmis_assessments, :days_homeless, :integer
  end
end
