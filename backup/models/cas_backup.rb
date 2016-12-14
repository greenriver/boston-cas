# encoding: utf-8

##
# Backup Generated: cas_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t cas_backup [-c <path_to_configuration_file>]
#
db_config = YAML.load_file('config/database.yml')['development']
notifier_config = Rails.application.config_for(:exception_notifier) rescue nil

Backup::Model.new(:cas, 'Description for cas_backup') do
  database PostgreSQL do |db|
    db.name           = db_config['database']
    db.host           = "localhost"
  end

  store_with Local do |local|
    local.path = '~/Desktop/'
  end

  compress_with Gzip

  notify_by Slack do |slack|
    slack.on_success = true
    slack.on_warning = true
    slack.on_failure = true

    # The integration token
    slack.webhook_url = notifier_config['slack']['webhook_url']
    slack.channel = notifier_config['slack']['channel']
    slack.username = 'CAS Backup'
  end
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

end
