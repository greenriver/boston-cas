class FixForUnavailableForsTimestamps < ActiveRecord::Migration
  def up
    change_column_default :unavailable_as_candidate_fors, :created_at, nil
    change_column_default :unavailable_as_candidate_fors, :updated_at, nil
  end
end
