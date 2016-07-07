class AddVerbToRules < ActiveRecord::Migration
  def change
    add_column :rules, :verb, :string
  end
end
