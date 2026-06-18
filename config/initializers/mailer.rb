###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# Require the custom mail delivery classes
require Rails.root.join('lib', 'util', 'mail', 'database_delivery')
require Rails.root.join('lib', 'util', 'mail', 'ses_delivery')

Rails.application.reloader.to_prepare do
  ActionMailer::Base.add_delivery_method :db, Mail::DatabaseDelivery
  ActionMailer::Base.add_delivery_method :ses, Mail::SesDelivery
end
