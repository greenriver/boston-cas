# frozen_string_literal: true

namespace :sentry do
  desc 'Send real test events through every Sentry.capture_* path this app uses, and report whether each was delivered'
  task verify: :environment do
    require_relative '../util/sentry_verifier'

    success = SentryVerifier.new.run!
    exit(1) unless success
  end
end
