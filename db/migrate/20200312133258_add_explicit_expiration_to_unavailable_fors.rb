class AddExplicitExpirationToUnavailableFors < ActiveRecord::Migration[6.0]
  def change
    add_column :unavailable_as_candidate_fors, :expires_at, :datetime, index: true
  end
end
