class AddCachedAsssessmentDetailsToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :assessed_at, :datetime
  end
end
