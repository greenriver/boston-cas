###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class StyleGuidesController < ApplicationController
  include PjaxModalController
  
  def dnd_match_review
    @enable_responsive = true
  end
  
end