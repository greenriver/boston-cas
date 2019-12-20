class AddVariableToRequirement < ActiveRecord::Migration[4.2]
  def change
    add_column :requirements, :variable, :string
  end
end
