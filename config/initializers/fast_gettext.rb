# db access is cached <-> only first lookup hits the db
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
