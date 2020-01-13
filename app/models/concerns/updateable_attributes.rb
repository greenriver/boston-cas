###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module UpdateableAttributes
  # a few methods that provide AR-like interface for
  # updating attributes
  #
  # the including object must implement #save

  def assign_attributes attrs = {}
    attrs.each { |attr, value| send "#{attr}=", value }
  end

  def update attrs = {}
    assign_attributes attrs
    save
  end

end