# NOTE: If you see this error
# I18n::InvalidLocale: :en is not a valid locale
# that probably means your database isn't fully set up, and you may
# need to comment out all Gettext gems in the Gemfile
# and remove this initializer temporarily
# db access is cached <-> only first lookup hits the db
def database_exists?
  ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
  false
else
  true
end
if database_exists? && ActiveRecord::Base.connection.table_exists?('translation_keys')
  require 'gettext_i18n_rails'
  require 'fast_gettext'
  require 'gettext'
  require "fast_gettext/translation_repository/db"
  FastGettext::TranslationRepository::Db.require_models #load and include default models

  FastGettext.add_text_domain(
    'boston-cas',
    :path => 'locale',
    :type => :db,
    :model => TranslationKey,
    :ignore_fuzzy => true,
    # :report_warning => false
  )
  FastGettext.default_available_locales = ['en']
  FastGettext.default_text_domain = 'boston-cas'
end
