class FileTag < ActiveRecord::Base
  belongs_to :sub_program

  def self.available_tags
    Warehouse::Tag.available
  end
end