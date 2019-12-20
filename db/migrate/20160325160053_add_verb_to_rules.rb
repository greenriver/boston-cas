class AddVerbToRules < ActiveRecord::Migration[4.2]
  def change
    add_column :rules, :verb, :string
  end
end
