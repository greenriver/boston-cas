set :deploy_to, "/var/www/#{fetch(:client)}-cas-staging"
set :rails_env, "staging"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

server ENV['STAGING_HOST'], user: fetch(:deploy_user), roles: %w{app db web job cron}, port: fetch(:ssh_port)

set :linked_dirs, fetch(:linked_dirs, []).push('certificates', 'key', '.well_known', 'challenge')

set :linked_files, fetch(:linked_files, []).push('config/letsencrypt_plugin.yml')

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
      end
    end
  end
end
