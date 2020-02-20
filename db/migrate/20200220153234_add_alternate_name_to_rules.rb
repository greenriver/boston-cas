class AddAlternateNameToRules < ActiveRecord::Migration[6.0]
  def change
    add_column :rules, :alternate_name, :string
  end
end
