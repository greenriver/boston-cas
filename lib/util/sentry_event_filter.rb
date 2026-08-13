###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# Scrubs sensitive parameters from a Sentry event before it's sent, mirroring
# Raven's old `config.sanitize_fields`. Used as `Sentry::Configuration#before_send`.
#
# Must mutate and return the event itself, not a Hash -- sentry-ruby's transport builds
# the envelope from whatever before_send returns, and several of its Event-specific checks
# (dynamic_sampling_context, attachments, item type) silently no-op or send a malformed
# item when that's a plain Hash instead of a Sentry::ErrorEvent.
class SentryEventFilter
  def initialize(filter_parameters)
    @filter = ActiveSupport::ParameterFilter.new(filter_parameters)
  end

  def call(event, _hint)
    event.tags = @filter.filter(event.tags)
    event.extra = @filter.filter(event.extra)
    event.contexts = @filter.filter(event.contexts)
    event.user = @filter.filter(event.user)

    if event.request
      event.request.data = @filter.filter(event.request.data) if event.request.data.is_a?(Hash)
      event.request.headers = @filter.filter(event.request.headers)
      event.request.env = @filter.filter(event.request.env)
      event.request.cookies = @filter.filter(event.request.cookies) if event.request.cookies.is_a?(Hash)
    end

    event
  end
end
