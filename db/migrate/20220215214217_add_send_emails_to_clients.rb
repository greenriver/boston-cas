class AddSendEmailsToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :send_emails, :boolean, default: false
  end
end
