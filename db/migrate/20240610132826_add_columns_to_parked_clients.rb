class AddColumnsToParkedClients < ActiveRecord::Migration[7.0]
  def change
    add_reference :unavailable_as_candidate_fors, :user
    add_reference :unavailable_as_candidate_fors, :match
    add_column :unavailable_as_candidate_fors, :reason, :string
  end
end
