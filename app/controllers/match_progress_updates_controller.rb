class MatchProgressUpdatesController < ApplicationController
  include HasMatchAccessContext

  def update
    raise params.inspect
  end

  def progress_params
    params.require()
  end
end