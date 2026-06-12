###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class StyleGuidesController < ApplicationController
  include AjaxModalRails::Controller

  def dnd_match_review
    @enable_responsive = true
  end

  def form
    @form = OpenStruct.new
  end

  private def guide_routes
    @guide_routes ||= {
      summary: 'Summary',
      dnd_match_review: 'DnD Match Review',
      form: 'Form Elements',
      icon_font: 'Icon Font',
      pagination: 'Pagination',
      stepped_progress: 'Stepped Progress',
      tags: 'Tags',
      typography: 'Typography',
    }
  end
  helper_method :guide_routes
end
