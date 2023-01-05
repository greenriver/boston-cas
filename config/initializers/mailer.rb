Rails.application.reloader.to_prepare do
  ActionMailer::Base.add_delivery_method :db, Mail::DatabaseDelivery
end
