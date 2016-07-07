module CasSeeds
  class Services

    def run!
      [
        'Case management',
        'Case manager on site 24 hours',
        'Case manager on site business hours',
        'Case manager on site as needed',
        'Case manager off site 24 hours',
        'Case manager off site business hours',
        'Case manager off site as needed',
        'Case Management - intensive',
        'Case Management - moderate',
        'Case Management - limited',
        'Services for Domestic Violence clients',
        'Mental Health Services',
        'Mental Health Services - independent',
        'Services for people with HIV/AIDS',
        'Services for elders',
        'Services for HUES clients',
        'Services for Women & families',
        'Services for families'
      ].each do |s|
        Service.where(name: s).first_or_create(name: s)
      end
    end

  end
end