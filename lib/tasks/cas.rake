namespace :cas do

  desc "Daily tasks"
  task daily: [:environment, "log:info_to_stdout"] do
    # re-set cache key for delayed job
    Rails.cache.write('deploy-dir', Delayed::Worker::Deployment.deployed_to)

    Warehouse::BuildReport.new.run! if Warehouse::Base.enabled?
    Warehouse::FlagHoused.new.run! if Warehouse::Base.enabled?
    Client.ensure_availability
    Cas::UpdateVoucherAvailability.new.run!
    UnavailableAsCandidateFor.cleanup_expired!
  end

  desc "Add/Update Clients with chronically homeless"
  task update_clients: [:environment, "log:info_to_stdout"] do
    exit if IdentifiedClient.advisory_lock_exists?('non_hmis_clients')
    IdentifiedClient.with_advisory_lock('non_hmis_clients') do
      # DataSource = 'Deidentified'
      IdentifiedClient.new.update_project_clients_from_non_hmis_clients
      DeidentifiedClient.new.update_project_clients_from_non_hmis_clients
      # DataSource = 'Imported'
      ImportedClient.new.update_project_clients_from_non_hmis_clients
    end
    exit if Client.advisory_lock_exists?('update_clients')
    Cas::UpdateClients.new.run!
  end

  desc "Add/Update ProjectClients from NonHmisClients"
  task update_project_clients_from_deidentified_clients: [:environment, "log:info_to_stdout"] do
    exit if IdentifiedClient.advisory_lock_exists?('non_hmis_clients')
    IdentifiedClient.with_advisory_lock('non_hmis_clients') do
      # DataSource = 'Deidentified'
      IdentifiedClient.new.update_project_clients_from_non_hmis_clients
      DeidentifiedClient.new.update_project_clients_from_non_hmis_clients
      # DataSource = 'Imported'
      ImportedClient.new.update_project_clients_from_non_hmis_clients
    end
  end

  desc "Update voucher availability based on future available dates"
  task update_voucher_availability: [:environment, "log:info_to_stdout"] do
    Cas::UpdateVoucherAvailability.new.run!
  end

  desc "Send status update requests for stalled matches"
  task request_status_updates: [:environment, "log:info_to_stdout"] do
    MatchProgressUpdates::Base.send_notifications
    MatchProgressUpdates::Base.batch_should_notify_dnd
  end

  desc "Add any missing tie breaker values to Clients"
  task add_missing_tie_breakers: [:environment, "log:info_to_stdout"] do
    Client.add_missing_tie_breakers
  end

  desc "Populate Match Census"
  task populate_match_census: [:environment, "log:info_to_stdout"] do
    MatchCensus.populate!
  end

end
