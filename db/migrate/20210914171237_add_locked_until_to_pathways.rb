class AddLockedUntilToPathways < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :locked_until, :date
    add_column :configs, :lock_days, :integer, default: 0, null: false
    add_column :configs, :lock_grace_days, :integer, default: 0, null: false
  end
end
