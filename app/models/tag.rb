class Tag < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  has_many :match_routes, class_name: MatchRoutes::Base.name

  scope :text_search, -> (text) do
    return none unless text.present?
    where(arel_table[:name].lower.matches("%#{text.downcase}%"))
  end

end
