class Neighborhood < ActiveRecord::Base
  scope :text_search, lambda { |text|
    return none unless text.present?

    where(arel_table[:name].lower.matches("%#{text.downcase}%"))
  }
end
