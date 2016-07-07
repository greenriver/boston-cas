class ProjectProgram < ActiveRecord::Base

  belongs_to :building, required: false

end
