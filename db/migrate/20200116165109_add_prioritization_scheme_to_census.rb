class AddPrioritizationSchemeToCensus < ActiveRecord::Migration
  def change
    add_reference :match_census, :match_prioritization, index: true
    add_column :match_census, :active_client_prioritization_value, :integer
    add_column :match_census, :prioritization_method_used, :string
  end
end
