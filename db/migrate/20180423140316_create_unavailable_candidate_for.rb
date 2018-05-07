class CreateUnavailableCandidateFor < ActiveRecord::Migration
  def change
    create_table :unavailable_as_candidate_fors do |t|
      t.references :client, null: false, index: true
      t.string :match_route_type, null: false, index: true
    end
  end
end
