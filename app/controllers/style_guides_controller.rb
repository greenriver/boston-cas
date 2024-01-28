###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class StyleGuidesController < ApplicationController
  include AjaxModalRails::Controller

  def dnd_match_review
    @enable_responsive = true
  end

  def form
    @form = OpenStruct.new
  end

end
