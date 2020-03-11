class RemoveNullConstraint < ActiveRecord::Migration[6.0]
  def change
    change_column_null :reporting_decisions, :source_data_source, false
  end
end
