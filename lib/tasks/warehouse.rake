namespace :warehouse do

  desc "pump the latest client matches and decisions into the HMIS database"
  task report: [:environment, "log:info_to_stdout"] do
    Warehouse::BuildReport.new.run! if Warehouse::Base.enabled?
  end

  desc "Flag CAS housed clients in the warehouse"
  task flag_housed: [:environment, "log:info_to_stdout"] do
    Warehouse::FlagHoused.new.run! if Warehouse::Base.enabled?
  end

end


