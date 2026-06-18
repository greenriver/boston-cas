###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :active_record_store, key: '_boston-ca_session', httponly: true, secure: Rails.env.production?
