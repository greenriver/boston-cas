###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/production/LICENSE.md
###

class Translation < ApplicationRecord
  include NotifierConfig

  def self.translate(text)
    # don't set expiry, the cache is updated via BuildTranslationCacheJob
    translated = Rails.cache.fetch(cache_key(text)) do
      translation = where(key: text).order(:id).first_or_create do |record|
        record.key = text
        Rails.logger.info("Unknown Translation key \"#{text}\", added to DB")
      end
      translation.text
    end
    translated.presence || text
  end

  def self.cache_key(text)
    digest = Digest::MD5.hexdigest(text.to_s)
    "translations/#{digest}"
  end

  def self.invalidate_translations_cache
    Rails.cache.delete_matched('translations/*')
  end

  def self.invalidate_translation_cache(key)
    Rails.cache.delete(cache_key(key))
  end

  def invalidate_cache
    self.class.invalidate_translation_cache(key)
  end

  def self.maintain_keys
    existing = pluck(:key)
    to_add = (known_translations - existing).map { |k| new(key: k) }
    import!(to_add)
  end

  # All known translations
  # Please insert new translations in alphabetical order and run:
  # Translation.maintain_keys
  def self.known_translations
    [
      '3D. Total # of Boston Homeless Nights',
      'Able to successfully exit 12-24 month RRH program',
      'Able to work full-time',
      'a criminal background hearing has been schedule for',
      'A criminal background hearing is not necessary',
      'Actively fleeing domestic violence in your home or staying with someone else',
      'Added to assessed clients',
      'Add Photo or Video Link',
      'Address of housing',
      'Administrative Cancelation',
      'Agency Interactions',
      'Another match is the top priority match.',
      'Any household member has been convicted of the manufacture or production of methamphetamine in federally assisted housing',
      'Any member of your household is subject to a lifetime registration requirement under a state sex offender registration program.',
      'Any neighborhood',
      'Asylee, Refugee',
      'Boston',
      'Boston Coordinated Access',
      'Boston Coordinated Access System',
      "Boston's Coordinated Access System",
      "Boston's Way Home",
      'Cannot read uploaded file, is it an XLSX?',
      'Can pass a drug test',
      'CAS',
      'Case Manager Name',
      'case worker',
      'case worker six',
      'Case Workers',
      'CAS Reports',
      'CE Assessment',
      'Challenges for housing placment',
      'Check off all the Boston neighborhoods you are willing to live in. Another way to decide is to figure out which places you will not live in, and check off the rest. You are not penalized if you change your mind about where you want to live.',
      'Children under age 18 in household',
      'Chronically homeless family',
      'City of Boston',
      'Clean/sober for at least one year',
      'Client',
      'Client Addresses',
      'Client Agrees to Match',
      'Client Agrees To Match',
      'Client Screening',
      'Client sent notice of criminal background hearing date.',
      'CoC Six',
      'CoC Eleven',
      'CoC Twelve',
      'CoC Thirteen',
      'Confirm Match Success',
      'Confirm Match Success Six',
      'CORI hearing',
      'Criminal Background Hearing',
      'Criminal Background Hearing Scheduled',
      'CSPECH Eligible',
      'Cumulative Days Homeless',
      'Cumulative days homeless, all-time',
      'Current Living Situation',
      'Currently fleeing DV',
      'Currently fleeing violence while in your own home or doubled up with others and a Boston resident.',
      'Current open case',
      'Date and time of criminal background hearing',
      'Date days homeless verified',
      'Days Homeless in Last Three Years',
      'Days Homeless in Last Three Years from HMIS',
      'Days homeless in the last three years including self-reported days',
      'Days in ES, SH or SO with no overlapping TH or PH',
      'Days in homeless enrollments, excluding any self-report',
      'Days Literally Homeless in Last Three Years',
      'Default Match Route',
      'De-identified Client',
      'De-Identified Clients',
      'determined mitigation not required',
      'determined mitigation required',
      'Development Officer',
      'Development Officer Contacts',
      'Development Officer Eight',
      'Development Officer Nine',
      'Did you or this client use external software to help with housing?',
      'DND',
      'Do not include client details in the note if you include the content in the email.',
      'Do you expect this client to be successful in this match?',
      'Earning a living wage ($13 or more)',
      'Emergency Shelter (includes domestic violence shelters)',
      'Emergency shelter in the City of Boston',
      'Employed for 3 or more months',
      'Employed full-time',
      'Ending Veteran & Chronic Homelessness in Boston',
      'Full HAN Release',
      'full release',
      'Gather information about a rapid re-housing (RRH) participant’s housing stability.',
      'HAN release',
      'has scheduled criminal background hearing for',
      'History of heavy drug use',
      'Homeless Set-Aside Route',
      'Housing Authority Eligible',
      'Housing Search Provider',
      'Housing Search Provider Eight',
      'Housing Search Provider Eleven',
      'Housing Search Provider Nine',
      'Housing Search Provider Thirteen',
      'Housing Search Providers',
      'Housing Search Worker',
      'housing subsidy administrator',
      'Housing Subsidy Administrator',
      'Housing Subsidy Administrator CORI Hearing',
      'Housing Subsidy Administrator Eight',
      'Housing Subsidy Administrator Eleven',
      'Housing Subsidy Administrator Nine',
      'Housing Subsidy Administrator Six',
      'Housing Subsidy Administrators',
      'Housing Subsidy Administrator status update',
      'HSA',
      'HSA Eight',
      'HSA Eleven',
      'HSA Twelve',
      'HSA Thirteen',
      'HSA Complete Match',
      'HSA Complete Match Six',
      'HSA Nine',
      'HSP',
      'Identified Client',
      'Identified Clients',
      'I don’t want to live in a roommate situation',
      'I don’t want to live in a single room',
      'I have a voucher to find a unit (Section 8, Housing Choice Voucher, CAS, MRVP, other)',
      'I have too little income and do not think I can increase it',
      'Imported',
      'I’m undecided but may reconsider',
      'indicates there will not be a criminal background hearing',
      'Ineligible Immigrant (Including Undocumented)',
      'Interested in income maximization services',
      'Interested in Transitional Housing',
      'I want to wait for subsidized housing',
      'Latest Date Eligible for Financial Assistance',
      'lease start date',
      'Lease start date',
      'Life-Time Sex Offender',
      'Limited CAS Release',
      'Match Route Eight',
      'Match Route Eleven',
      'Match Route Five',
      'Match Route Four',
      'Match Route Nine',
      'Match Route Seven',
      'Match Route Six',
      'Match Route Ten',
      'Match Route Twelve',
      'Match Route Thirteen',
      'match shelter agency agreement modal',
      'Match status update',
      'Meth Production Conviction',
      'Mitigation',
      'Mitigation is not required',
      'Mitigation required',
      'Move In',
      'Multiple Match Disclaimer',
      'Needs a higher level of care',
      'Needs ongoing housing case management',
      'Needs site-based case management',
      'Neighborhoods you are willing to live in.',
      'No criminal background hearing was requested.',
      'No, I do not know anyone to share housing with',
      'No, I have had negative roommate experiences before',
      'No, I want my own home',
      'No mitigation required',
      'None of the above ',
      'Non-HMIS Clients',
      'No preference, any agency',
      'Outside/place not meant for human habitation within the City of Boston',
      'Part of a family',
      'Photos and Videos',
      'Project-Based unit: The unit is affordable (about 30-40% of your income), but the affordability is attached to the unit. It is not mobile- if you leave, you will lose the affordability. You do not have to do a full housing search in the private market with landlords because the actual unit would be open and available.',
      'Provider Only Route',
      'Public Housing unit',
      'Qualified Opportunities',
      'Record Date Voucher Issued',
      'Release of information',
      'Remember to check housing availablility',
      'Requires ground floor unit or elevator access',
      'Requires wheelchair accessible unit',
      'researching criminal background and deciding whether to schedule a hearing',
      'RH Staff at Bridge Over Troubled Water (youth agency)',
      'Route Five Development Officer',
      'Route Five DND Contact',
      'Route Five Housing Search Provider',
      'Route Five HSA',
      'Route Five Shelter Agency',
      'Route Five Stabilization Service Provider',
      'RRH staff at 112 Southampton Street Shelter',
      'RRH Staff at Casa Myrna Vazquez (domestic violence agency)',
      'RRH Staff at Elizabeth Stonehouse (domestic violence agency)',
      'RRH staff at HomeStart',
      'RRH staff at Pine Street Inn',
      'RRH staff at Woods Mullen Shelter',
      'sent notice of criminal background hearing date.',
      'Shelter Agency',
      'Shelter Agency Contact',
      'Shelter Agency Contacts',
      'Shelter Agency Eight',
      'Shelter Agency Eleven',
      'Shelter Agency Nine',
      'Shelter Agency Six',
      'Shelter Agency Twelve',
      'Shelter Agency Thirteen',
      'shelter case manager',
      'Should this tag be added to anyone with an assessment score?',
      'SSP',
      'SSP Eleven',
      'Stabilization Service Provider',
      'Stabilization Service Provider Eight',
      'Stabilization Service Provider Eleven',
      'Stabilization Service Provider Nine',
      'Stabilization Service Providers',
      'Stabilization Services Provider',
      'Stabilization Service Providers Eleven',
      'Stabilization Service Providers Thirteen',
      'Staff Decline',
      'Strengths',
      'Submit Client Application',
      'Tag',
      'Tags',
      'TC HAT',
      'The Boston Coordinated Access System is operated by the Department of Neighborhood Development as the lead agency of the Boston Continuum of Care.',
      'The client does not need to be document-ready in order to indicate interest.',
      'The file header is incorrect.',
      'There will be a criminal background hearing',
      'There will not be a criminal background hearing',
      'they can proceed to determine whether a criminal background hearing is needed. You will be notified when they either accept the match or schedule a hearing.',
      "This email was automatically generated by Boston's Coordinated Access System.",
      'Transitional Housing',
      'Transitional housing program in the City of Boston',
      'Translate this to add voucher confirmation',
      'translation',
      'Unable to upload file, is it a CSV?',
      'Unsheltered (outside, in a place not meant for human habitation, etc.)',
      'Uploaded file does not have the correct header. Incorrect file?',
      'U.S Citizen or Permanent Resident',
      'View details here: Six',
      'Veteran Agency Contact Details',
      'Voucher: An affordable housing \ticket\ used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)',
      'Voucher: An affordable housing “ticket” used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)',
      'was sent full details of match for review and scheduling of any necessary criminal background hearings',
      'We want to reach you when there is a housing program opening for you.',
      'When you indicate interest, notification will be sent to the',
      'Willing to engage with housing case management',
      'Willing to work full-time',
      'Yes',
      'You must attach a file in the form.',
      'Youth in foster care',
    ]
  end
end
