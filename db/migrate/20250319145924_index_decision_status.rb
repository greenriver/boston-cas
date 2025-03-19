class IndexDecisionStatus < ActiveRecord::Migration[7.0]
  def change
    add_index :match_decisions, :status, where: "(deleted_at IS NULL)"
  end
end
