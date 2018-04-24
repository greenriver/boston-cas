class AddMatchPrioritization < ActiveRecord::Migration
  def change
    create_table :match_prioritizations do |t|
      t.string :type, null: false
      t.boolean :active, null: false, default: true
      t.integer :weight, null: false, default: 10
      t.timestamps null: false
    end

    MatchPrioritization::Base.ensure_all
    default_priority = MatchPrioritization::DaysHomelessLastThreeYears.first.id || 0

    add_reference :match_routes, :match_prioritization, null: false, default: default_priority
    remove_column :configs, :engine_mode, :string, null: false, default: 'first-date-homeless'

  end
end
