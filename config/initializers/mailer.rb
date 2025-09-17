# Require the custom mail delivery class
require Rails.root.join('lib', 'util', 'mail', 'database_delivery')

Rails.application.reloader.to_prepare do
  ActionMailer::Base.add_delivery_method :db, Mail::DatabaseDelivery
end
