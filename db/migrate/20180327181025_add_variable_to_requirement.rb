class AddVariableToRequirement < ActiveRecord::Migration
  def change
    add_column :requirements, :variable, :string
  end
end
