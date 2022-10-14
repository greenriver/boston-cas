def hud_codes
  # HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.1 Name
  {
    1 => 'Full name reported',
    2 => 'Partial, street name, or code name reported',
    8 => 'Client doesn’t know',
    9 => 'Client refused'
  }.each do |id, name|
    item = NameQualityCode.where(numeric: id).first_or_create! do |r|
      r.numeric = id
      r.text = name
    end
    item.text = name
    item.save
  end
  # HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.2 Social Security Number
  {
    1 => 'Full SSN reported',
    2 => 'Approximate or partial SSN reported',
    8 => 'Client doesn’t know',
    9 => 'Client refused',
    99 => 'Data not collected'
  }.each do |id, name|
    item = SocialSecurityNumberQualityCode.where(numeric: id).first_or_create! do |r|
      r.numeric = id
      r.text = name
    end
    item.text = name
    item.save
  end
  # HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.3 Date of Birth
  {
    1 => 'Full DOB reported',
    2 => 'Approximate or partial DOB reported',
    8 => 'Client doesn’t know',
    9 => 'Client refused',
    99 => 'Data not collected'
  }.each do |id, name|
    item = DateOfBirthQualityCode.where(numeric: id).first_or_create! do |r|
      r.numeric = id
      r.text = name
    end
    item.text = name
    item.save
  end
  # HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.5 Ethnicity
  Ethnicity.where(text: 'Other (Non-Hispanic/Latino)').delete_all
  {
    0 => 'Non-Hispanic/Non-Latino',
    1 => 'Hispanic/Latino',
    8 => 'Client doesn’t know',
    9 => 'Client refused',
    99 => 'Data not collected'
  }.each do |id, name|
    item = Ethnicity.where(numeric: id).first_or_create! do |r|
      r.numeric = id
      r.text = name
    end
    item.text = name
    item.save
  end
  # 3.7 VeteranStatus
  {
    0 => 'No',
    1 => 'Yes',
    8 => 'Client doesn’t know',
    9 => 'Client refused',
    99 => 'Data not collected'
  }.each do |id, name|
    item = VeteranStatus.where(numeric: id).first_or_create! do |r|
      r.numeric = id
      r.text = name
    end
    item.text = name
    item.save
  end
  # 3.8 DisablingCondition
  {
    0 => 'No',
    1 => 'Yes',
    8 => 'Client doesn’t know',
    9 => 'Client refused',
    99 => 'Data not collected'
  }.each do |id, name|
    item = DisablingCondition.where(numeric: id).first_or_create! do |r|
      r.numeric = id
      r.text = name
    end
    item.text = name
    item.save
  end

  [
    'HUD: CoC - Permanent Supportive Housing',
    'HUD: CoC - Rapid Re-Housing'
  ].each do |name|
    FundingSource.where(name: name).first_or_create!(name: name)
  end
end

# Reports
def report_list
  {
    'Operational Reports' => [
      {
        url: 'reports/parked_clients',
        name: 'Parked Clients',
        description: 'The currently parked clients.',
        limitable: false,
      },
      {
        url: 'reports/dashboards/overviews',
        name: 'Dashboard',
        description: 'Match, vacancy, and client dashboards.',
        limitable: true,
      },
      {
        url: 'reports/match_progress',
        name: 'Match Progress',
        description: 'CAS match progress tracking report',
        limitable: true,
      },
      {
        url: 'reports/housed_addresses',
        name: 'Housed Client Addresses',
        description: 'Addresses of successfully housed clients.',
        limitable: true,
      },
      {
        url: 'reports/agency_interactions',
        name: 'Agency Interactions',
        description: 'Report of agency interactions with matches.',
        limitable: true,
      },
      {
        url: 'reports/external_referrals',
        name: 'External Referrals',
        description: 'Export referral list and optionally generate referrals for HUD reporting in the warehouse.',
        limitable: false,
      },
    ],
  }
end

def cleanup_unused_reports
  [
  ].each do |url|
    ReportDefinition.where(url: url).delete_all
  end
end

def maintain_report_definitions
  cleanup_unused_reports()
  report_list.each do |category, reports|
    reports.each do |report|
      r = ReportDefinition.where(url: report[:url]).first_or_initialize
      r.report_group = category
      r.name = report[:name]
      r.description = report[:description]
      r.limitable = report[:limitable]
      r.save
    end
  end
end

hud_codes
StalledResponse.ensure_all
maintain_report_definitions
# force config refresh
Config.first&.invalidate_cache
