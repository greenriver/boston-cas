class ReplaceCodeIdentWithTypeForRules < ActiveRecord::Migration
  def change
    remove_column :rules, :code_ident, :string
    add_column :rules, :type, :string
  end
end
