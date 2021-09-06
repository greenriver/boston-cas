namespace :warehouse do

  desc 'Pump the latest client matches and decisions into the HMIS database'
  task report: [:environment, 'log:info_to_stdout'] do
    Warehouse::BuildReport.new.run! if Warehouse::Base.enabled?
  end

  desc 'Flag CAS housed clients in the warehouse'
  task :flag_housed, [:clear] => [:environment, 'log:info_to_stdout'] do |_, args|
    clear = args[:clear] == 'clear'
    Warehouse::FlagHoused.new.run!(clear) if Warehouse::Base.enabled?
  end

  desc 'Sync CE data'
  task sync_ce_data: [:environment, 'log:info_to_stdout'] do
    Warehouse::CeAssessment.sync!
    Warehouse::ReferralEvent.sync!
  end
end
