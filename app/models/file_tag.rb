class FileTag < ActiveRecord::Base
  belongs_to :sub_program

  def self.available_tags
    return [] unless Warehouse::Base.enabled?

    Warehouse::Tag.available
  end
end
