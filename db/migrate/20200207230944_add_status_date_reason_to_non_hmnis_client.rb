class AddStatusDateReasonToNonHmnisClient < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :available_date, :datetime
    add_column :non_hmis_clients, :available_reason, :string
  end
end
