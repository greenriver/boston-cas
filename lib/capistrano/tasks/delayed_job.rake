# Do not use capistrano-delayed job gem as it's not needed.

namespace :delayed_job do
  task :restart do
    on roles(:job) do
      execute :sudo, "bash -l -c 'systemctl stop delayed_job-#{fetch(:client)}-cas-#{fetch(:rails_env)}.0.service || echo ok'"

      execute :sudo, "systemctl start delayed_job-#{fetch(:client)}-cas-#{fetch(:rails_env)}.0.service"
    end
  end

  task :stop do
    on roles(:job) do
      execute :sudo, "bash -l -c 'systemctl stop delayed_job-#{fetch(:client)}-cas-#{fetch(:rails_env)}.0.service || echo ok'"
    end
  end

  task :start do
    on roles(:job) do
      execute :sudo, "systemctl start delayed_job-#{fetch(:client)}-cas-#{fetch(:rails_env)}.0.service"
    end
  end
end