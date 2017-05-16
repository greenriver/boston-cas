set :deploy_to, '/var/www/boston-cas-production'
set :rails_env, "production"

raise "You must specify DEPLOY_USER" if ENV['DEPLOY_USER'].to_s == ''

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

server ENV['HOST1'], user: ENV['DEPLOY_USER'], roles: %w{app db web}
server ENV['HOST2'], user: ENV['DEPLOY_USER'], roles: %w{app web}

namespace :deploy do
  before :finishing, :seed_rules do
    on roles(:db)  do
      within current_path do
        execute :rake, 'cas_seeds:create_rules RAILS_ENV=production'
        execute :rake, 'cas_seeds:create_match_decision_reasons RAILS_ENV=production'
      end
    end
  end
  before :finishing, :nginx_restart do
    on roles(:web) do
      execute :sudo, '/etc/init.d/nginx restart'
    end
  end
end
