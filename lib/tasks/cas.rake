namespace :cas do

  desc 'Daily tasks'
  task daily: [:environment, 'log:info_to_stdout'] do
    # re-set cache key for delayed job
    Rails.cache.write('deploy-dir', Delayed::Worker::Deployment.deployed_to)

    Warehouse::BuildReport.new.run! if Warehouse::Base.enabled?
    Warehouse::FlagHoused.new.run! if Warehouse::Base.enabled?
    # Client.ensure_availability
    Cas::UpdateVoucherAvailability.new.run!
    UnavailableAsCandidateFor.cleanup_expired!
    Matching::RunEngineJob.perform_later
    ClientOpportunityMatch.send_summary_emails
  end

  desc 'Hourly tasks'
  task hourly:  [:environment, 'log:info_to_stdout'] do
    # attempt to keep the matched counts in sync.
    SubProgram.find_each do |sp|
      sp.update_summary!
    end
    Client.add_missing_tie_breakers
  end

  desc 'Add/Update Clients with chronically homeless'
  task update_clients: [:environment, 'log:info_to_stdout'] do
    unless IdentifiedClient.advisory_lock_exists?('non_hmis_clients')
      IdentifiedClient.with_advisory_lock('non_hmis_clients') do
        # DataSource = 'Deidentified'
        IdentifiedClient.new.update_project_clients_from_non_hmis_clients
        DeidentifiedClient.new.update_project_clients_from_non_hmis_clients
        # DataSource = 'Imported'
        ImportedClient.new.update_project_clients_from_non_hmis_clients
      end
    end
    Cas::UpdateClients.new.run! unless Client.advisory_lock_exists?('update_clients')
  end

  desc 'Add/Update ProjectClients from NonHmisClients'
  task update_project_clients_from_deidentified_clients: [:environment, 'log:info_to_stdout'] do
    unless IdentifiedClient.advisory_lock_exists?('non_hmis_clients')
      IdentifiedClient.with_advisory_lock('non_hmis_clients') do
        # DataSource = 'Deidentified'
        IdentifiedClient.new.update_project_clients_from_non_hmis_clients
        DeidentifiedClient.new.update_project_clients_from_non_hmis_clients
        # DataSource = 'Imported'
        ImportedClient.new.update_project_clients_from_non_hmis_clients
      end
    end
  end

  desc 'Update voucher availability based on future available dates'
  task update_voucher_availability: [:environment, 'log:info_to_stdout'] do
    Cas::UpdateVoucherAvailability.new.run!
  end

  desc 'Send status update requests for stalled matches'
  task request_status_updates: [:environment, 'log:info_to_stdout'] do
    MatchProgressUpdates::Base.send_notifications
    MatchProgressUpdates::Base.batch_should_notify_dnd
  end

  desc 'Add any missing tie breaker values to Clients'
  task add_missing_tie_breakers: [:environment, 'log:info_to_stdout'] do
    Client.add_missing_tie_breakers
  end

  desc 'Populate Match Census'
  task populate_match_census: [:environment, 'log:info_to_stdout'] do
    MatchCensus.populate!
  end

  desc 'Update clients with voucher status'
  task add_missing_holds_voucher_on: [:environment, 'log:info_to_stdout'] do
    Client.add_missing_holds_voucher_on
  end
end
