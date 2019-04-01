class StyleGuidesController < ApplicationController
  include PjaxModalController

  def dnd_match_review
    @enable_responsive = true
  end
end
