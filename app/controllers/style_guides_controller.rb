###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class StyleGuidesController < ApplicationController
  include PjaxModalController

  def dnd_match_review
    @enable_responsive = true
  end

  def form
    @form = OpenStruct.new
  end

end
