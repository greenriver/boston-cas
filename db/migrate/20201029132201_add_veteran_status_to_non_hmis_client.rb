class AddVeteranStatusToNonHmisClient < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :veteran_status, :string
  end
end
