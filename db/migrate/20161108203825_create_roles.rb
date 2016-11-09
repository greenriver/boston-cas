class CreateRoles < ActiveRecord::Migration
  def up
    create_table :roles do |t|
      t.string :name, null: false, index: true, unique: true
      t.timestamps null: false
    end

    permissions = [
      :can_view_all_clients, 
      :can_edit_all_clients,
      :can_participate_in_matches,
      :can_view_all_matches,
      :can_see_alternate_matches,
      :can_edit_match_contacts,
      :can_approve_matches,
      :can_reject_matches,
      :can_act_on_behalf_of_match_contacts,
      :can_view_reports, 
      :can_edit_roles, 
      :can_edit_users, 
      :can_view_full_ssn, 
      :can_view_full_dob,  
      :can_view_buildings, 
      :can_edit_buildings, 
      :can_view_funding_sources, 
      :can_edit_funding_sources, 
      :can_view_subgrantees, 
      :can_edit_subgrantees, 
      :can_view_vouchers, 
      :can_edit_vouchers, 
      :can_view_programs, 
      :can_edit_programs, 
      :can_view_opportunities, 
      :can_edit_opportunities, 
      :can_reissue_notifications, 
      :can_view_units, 
      :can_edit_units, 
      :can_add_vacancies,
      :can_view_contacts,
      :can_edit_contacts,
      :can_view_rule_list,
      :can_edit_rule_list,
      :can_view_available_services,
      :can_edit_available_services,
      :can_assign_services,
      :can_assign_requirements,
    ]
    permissions.each do |permission|
      add_column :roles, permission, :boolean, default: false
    end

    create_table :user_roles do |t|
      t.belongs_to :role, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end

    add_foreign_key :user_roles, :roles, on_delete: :cascade
    add_foreign_key :user_roles, :users, on_delete: :cascade

    admin = Role.where(name: 'admin').first_or_create
    dnd = Role.where(name: 'dnd_staff').first_or_create
    hsa = Role.where(name: 'hsa').first_or_create
    shelter_agency = Role.where(name: 'shelter_agency').first_or_create
    client_contact = Role.where(name: 'client_contact').first_or_create

    Rails.logger.info "Setting default permissions"
    admin.update(Role.permissions.map{|m| [m, true]}.to_h)
    dnd.update(Role.permissions.map{|m| [m, true]}.to_h)
    hsa.update({
      can_participate_in_matches: true,
      can_add_vacancies: true,
      can_view_vouchers: true,
      can_edit_vouchers: true,
      can_view_programs: true,
      can_view_opportunities: true,
    })
    shelter_agency.update({can_participate_in_matches: true})
    client_contact.update({can_participate_in_matches: true})

    Rails.logger.info "Adding roles to current users"
    User.where(admin: true).each do |u|
      if u.roles.present?
        u.roles += [admin]
      else
        u.roles = [admin]
      end
    end
    User.where(dnd_staff: true).each do |u|
      if u.roles.present?
        u.roles += [dnd]
      else
        u.roles = [dnd]
      end
    end
    User.where(housing_subsidy_admin: true).each do |u|
      if u.roles.present?
        u.roles += [hsa]
      else
        u.roles = [hsa]
      end
    end

    remove_column :users, :admin
    remove_column :users, :dnd_staff
    remove_column :users, :housing_subsidy_admin

  end
  def down
    add_column :users, :admin, :boolean, default: false
    add_column :users, :dnd_staff, :boolean, default: false
    add_column :users, :housing_subsidy_admin, :boolean, default: false

    User.joins(:roles).where(roles: {name: 'admin'}).each do |u|
      u.update(admin: true)
    end
    User.joins(:roles).where(roles: {name: 'dnd_staff'}).each do |u|
      u.update(dnd_staff: true)
    end
    User.joins(:roles).where(roles: {name: 'hsa'}).each do |u|
      u.update(housing_subsidy_admin: true)
    end

    drop_table :user_roles
    drop_table :roles

  end
end
