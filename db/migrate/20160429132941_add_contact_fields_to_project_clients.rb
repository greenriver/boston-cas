class AddContactFieldsToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :homephone, :string
    add_column :project_clients, :cellphone, :string
    add_column :project_clients, :workphone, :string
    add_column :project_clients, :pager, :string
    add_column :project_clients, :email, :string

    add_column :clients, :homephone, :string
    add_column :clients, :cellphone, :string
    add_column :clients, :workphone, :string
    add_column :clients, :pager, :string
    add_column :clients, :email, :string
    
  end
end
