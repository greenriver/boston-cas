namespace :hmis do
  
  desc "pump the latest client matches and decisions into the HMIS database"
  task report: [:environment, "log:info_to_stdout"] do
    Hmis::BuildReport.new.run!
  end

end


