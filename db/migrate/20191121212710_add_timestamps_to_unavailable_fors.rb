class AddTimestampsToUnavailableFors < ActiveRecord::Migration
  def change
    change_table :unavailable_as_candidate_fors do |t|
      t.timestamps null: false, default: Time.current
    end
  end
end
