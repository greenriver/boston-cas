class ReplaceCodeIdentWithTypeForRules < ActiveRecord::Migration[4.2]
  def change
    remove_column :rules, :code_ident, :string
    add_column :rules, :type, :string
  end
end
