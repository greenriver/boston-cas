namespace :warehouse do
  
  desc "pump the latest client matches and decisions into the HMIS database"
  task report: [:environment, "log:info_to_stdout"] do
    Warehouse::BuildReport.new.run!
  end

end


