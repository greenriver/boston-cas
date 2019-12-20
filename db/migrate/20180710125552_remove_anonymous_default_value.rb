class RemoveAnonymousDefaultValue < ActiveRecord::Migration[4.2]
  def change
    change_column_default :deidentified_clients, :first_name, nil
    change_column_default :deidentified_clients, :last_name, nil
  end
end
