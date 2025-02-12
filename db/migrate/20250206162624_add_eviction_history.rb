class AddEvictionHistory < ActiveRecord::Migration[7.0]
  def change
    add_column :non_hmis_assessments, :eviction_history, :string
  end
end
