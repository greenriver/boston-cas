class AddTimestampsToUnavailableFors < ActiveRecord::Migration[4.2]
  def change
    change_table :unavailable_as_candidate_fors do |t|
      t.timestamps null: false, default: Time.current
    end

    Config.reset_column_information
    Config.first.save
  end
end
