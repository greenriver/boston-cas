###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
