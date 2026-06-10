class AddVacancyPermissionsToRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :can_review_vacancies, :boolean, default: false, null: false
  end
end
