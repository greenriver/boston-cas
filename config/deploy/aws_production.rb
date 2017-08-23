set :deploy_to, "/var/www/#{fetch(:client)}-cas-production"
set :rails_env, "production"

raise "You must specify DEPLOY_USER" if ENV['DEPLOY_USER'].to_s == ''

set :branch, 'master'
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Delayed Job
set :delayed_job_workers, 2
set :delayed_job_prefix, "#{ENV['CLIENT']}-cas"
set :delayed_job_roles, [:job]

puts "Allowable hosts: #{ENV['HOSTS']}"
puts "Hosts specified for deployment: #{ENV['HOST1']} #{ENV['HOST2']} #{ENV['HOST3']}"

server ENV['HOST1'], user: ENV['DEPLOY_USER'], roles: %w{app db web}
server ENV['HOST2'], user: ENV['DEPLOY_USER'], roles: %w{app web job}
server ENV['HOST3'], user: ENV['DEPLOY_USER'], roles: %w{app web}

set :linked_dirs, fetch(:linked_dirs, []).push('certificates', 'key', '.well_known', 'challenge')

set :linked_files, fetch(:linked_files, []).push('config/letsencrypt_plugin.yml')

namespace :deploy do
  before :published, :translations do
    on roles(:db)  do
      within release_path do
        execute :rake, 'gettext:sync_to_po_and_db RAILS_ENV=production'
      end
    end
  end
  before :finishing, :seed_rules do
    on roles(:db)  do
      within current_path do
        execute :rake, 'cas_seeds:create_rules RAILS_ENV=production'
        execute :rake, 'cas_seeds:create_match_decision_reasons RAILS_ENV=production'
      end
    end
  end
end
