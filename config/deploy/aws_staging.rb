set :deploy_to, '/var/www/boston-cas-staging'
set :rails_env, "staging"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

server ENV['STAGING_HOST'], user: 'ubuntu', roles: %w{app db web}

<<<<<<< HEAD
set :linked_dirs, fetch(:linked_dirs, []).push('certificates', 'key', '.well_known', 'challenge')

set :linked_files, fetch(:linked_files, []).push('config/letsencrypt_plugin.yml')

=======
>>>>>>> aws-capistrano
namespace :deploy do
  before :finishing, :seed_rules do
    on roles(:db)  do
      within current_path do
        execute :rake, 'cas_seeds:create_rules RAILS_ENV=staging'
        execute :rake, 'cas_seeds:create_match_decision_reasons RAILS_ENV=staging'
      end
    end
  end
<<<<<<< HEAD
end

=======
  before :finishing, :nginx_restart do
    on roles(:web) do
      execute :sudo, '/etc/init.d/nginx restart'
    end
  end
end
>>>>>>> aws-capistrano
