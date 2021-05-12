set :deploy_to, "/var/www/#{fetch(:client)}-cas-staging"
set :rails_env, "staging"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

web_hosts = ENV['STAGING_HOSTS_WEB'].to_s.split(/,/)
utility_hosts = ENV['STAGING_HOSTS_UTILITY'].to_s.split(/,/)
cron_host = ENV['STAGING_HOST_WITH_CRON']

hosts = (web_hosts + utility_hosts + [cron_host]).uniq.sort

puts "Hosts specified for deployment: #{hosts}"

hosts.each do |host|
  roles = ['app']

  roles << 'web' if web_hosts.include?(host)
  roles << 'job' if utility_hosts.include?(host)
  roles << 'db' if cron_host == host
  roles << 'cron' if cron_host == host

  server host, user: ENV['DEPLOY_USER'], roles: roles, port: fetch(:ssh_port)
end

namespace :deploy do
  before :published, :translations do
    on roles(:db)  do
      within release_path do
        execute :rake, 'gettext:sync_to_po_and_db RAILS_ENV=staging'
      end
    end
  end
  before :finishing, :seed_rules do
    on roles(:db)  do
      within current_path do
        execute :rake, 'cas_seeds:create_rules RAILS_ENV=staging'
        execute :rake, 'cas_seeds:create_match_decision_reasons RAILS_ENV=staging'
        execute :rake, 'cas_seeds:ensure_all_match_routes_exist RAILS_ENV=staging'
        execute :rake, 'cas_seeds:ensure_all_match_prioritization_schemes_exist RAILS_ENV=staging'
        execute :rake, 'cas_seeds:stalled_reasons RAILS_ENV=staging'
        execute :rake, 'cas_seeds:create_mitigation_reasons RAILS_ENV=staging'
      end
    end
  end
end
