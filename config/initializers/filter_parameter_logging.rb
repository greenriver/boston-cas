# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :passw,
  :secret,
  :token,
  :_key,
  :crypt,
  :salt,
  :encrypted,
  :certificate,
  :otp,
  :ssn,
  :dob,
  :date_of_birth,
  :first_name,
  :last_name,
  :FirstName,
  :LastName,
  :alternate_names,
  :medicaid,
  :medicare,
  :mass_health_id,
  :aliases,
  :birthdate,
  :hiv,
  :middle,
  :nick,
  :cell,
  :phone,
  :email,
  :zip,
  :aliases,
  :birthdate,
]
