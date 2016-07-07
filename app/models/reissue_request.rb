class ReissueRequest < ActiveRecord::Base
  belongs_to :notification, class_name: 'Notifications::Base'

  acts_as_paranoid
  has_paper_trail
end
