class AddManagerToDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decisions, :manager, :string
  end
end
