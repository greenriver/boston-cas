namespace :cas do
  
  desc "Daily tasks"
  task daily: [:environment, "log:info_to_stdout"] do
    Warehouse::BuildReport.new.run!
    Warehouse::FlagHoused.new.run!
    Cas::UpdateVoucherAvailability.new.run!
  end

  desc "Add/Update Clients with chronically homeless"
  task update_clients: [:environment, "log:info_to_stdout"] do
    Cas::UpdateClients.new.run!
  end
  
  desc "Add/Update ProjectClients from DeidentifiedClients"
  task update_project_clients_from_deidentified_clients: [:environment, "log:info_to_stdout"] do
    DeidentifiedClient.new.update_project_clients_from_deidentified_clients
  end

  desc "Update voucher avaiability based on future available dates"
  task update_voucher_availability: [:environment, "log:info_to_stdout"] do
    Cas::UpdateVoucherAvailability.new.run!
  end

  desc "Send status update requests for stalled matches"
  task request_status_updates: [:environment, "log:info_to_stdout"] do
    MatchProgressUpdates::Base.send_notifications
    MatchProgressUpdates::Base.batch_should_notify_dnd
  end

  desc "Ensure all active matches have status update requests"
  task ensure_status_updates: [:environment, "log:info_to_stdout"] do
    ClientOpportunityMatch.active.each do |match|
      match.shelter_agency_contacts.each do |contact|
        MatchProgressUpdates::ShelterAgency.where(
          contact_id: contact.id, 
          match_id: match.id,
        ).first_or_create do |update|
          update.notification_number = 0
        end
      end
      match.ssp_contacts.each do |contact|
        MatchProgressUpdates::Ssp.where(
          contact_id: contact.id, 
          match_id: match.id,
        ).first_or_create do |update|
          update.notification_number = 0
        end
      end
      match.hsp_contacts.each do |contact|
        MatchProgressUpdates::Hsp.where(
          contact_id: contact.id, 
          match_id: match.id,
        ).first_or_create do |update|
          update.notification_number = 0
        end
      end
    end
  end

end
