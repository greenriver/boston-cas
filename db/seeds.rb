# HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.1 Name
{
  1 => 'Full name reported',
  2 => 'Partial, street name, or code name reported',
  8 => 'Client doesn’t know',
  9 => 'Client refused'
}.each do |id, name|
  NameQualityCode.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.2 Social Security Number
{
  1 => 'Full SSN reported',
  2 => 'Approximate or partial SSN reported',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  SocialSecurityNumberQualityCode.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.3 Date of Birth
{
  1 => 'Full DOB reported',
  2 => 'Approximate or partial DOB reported',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  DateOfBirthQualityCode.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.6 Gender
{
  0 => 'Female',
  1 => 'Male',
  2 => 'Transgender male to female',
  3 => 'Transgender female to male',
  4 => 'Doesn’t identify as male, female, or transgender',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  Gender.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.4 Race
{
  1 => 'American Indian or Alaska Native',
  2 => 'Asian',
  3 => 'Black or African American',
  4 => 'Native Hawaiian or Other Pacific Islander',
  5 => 'White',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  Race.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# HUD HMIS Data Standards UNIVERSAL DATA ELEMENTS 3.5 Ethnicity
{
  0 => 'Non-Hispanic/Non-Latino',
  1 => 'Hispanic/Latino',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  Ethnicity.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# 3.7 VeteranStatus
{
  0 => 'No',
  1 => 'Yes',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  VeteranStatus.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end
# 3.8 DisablingCondition
{
  0 => 'No',
  1 => 'Yes',
  8 => 'Client doesn’t know',
  9 => 'Client refused',
  99 => 'Data not collected'
}.each do |id, name|
  DisablingCondition.where(numeric: id, text: name).first_or_create! do |r|
    r.numeric = id
    r.text = name
  end
end

[
  'HUD: CoC - Permanent Supportive Housing',
  'HUD: CoC - Rapid Re-Housing'
].each do |name|
  FundingSource.where(name: name).first_or_create!(name: name)
end
