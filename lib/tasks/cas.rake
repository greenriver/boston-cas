namespace :cas do
  
  desc "Add/Update Clients with chronically homeless"
  task update_clients: [:environment, "log:info_to_stdout"] do
    Cas::UpdateClients.new.run!
  end

  desc "Update voucher avaiability based on future available dates"
  task update_voucher_availability: [:environment, "log:info_to_stdout"] do
    Cas::UpdateVoucherAvailability.new.run!
  end

end


