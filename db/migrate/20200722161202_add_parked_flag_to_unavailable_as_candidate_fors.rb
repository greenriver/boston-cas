class AddParkedFlagToUnavailableAsCandidateFors < ActiveRecord::Migration[6.0]
  def change
    add_column :unavailable_as_candidate_fors, :parked, :boolean, default: false
  end
end
