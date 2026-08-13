###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# Sends real test events through every Sentry.capture_* path this app actually uses
# (grep app/ lib/ for the current list) and reports whether each one round-tripped to
# Sentry successfully. Meant to be run by hand -- via `rake sentry:verify` -- against a
# real CAS_SENTRY_DSN when you need to confirm delivery, not as part of the test suite.
#
# By default Sentry sends events from a background thread and swallows delivery errors
# (network failures, non-2xx responses) into a debug-only log line, so a successful-looking
# `Sentry.capture_exception` call proves nothing about actual delivery. This verifier forces
# synchronous sending (background_worker_threads = 0) so a failed send returns nil instead of
# silently vanishing, and turns on config.debug so the underlying HTTP failure reason (if any)
# reaches the log.
class SentryVerifier
  Outcome = Struct.new(:check, :sent, keyword_init: true)

  def initialize(output: $stdout)
    @output = output
  end

  def run!
    unless Sentry.initialized?
      @output.puts 'Sentry.initialized? is false -- CAS_SENTRY_DSN is missing, or Rails.env is not in config.enabled_environments. Nothing to verify.'
      return false
    end

    report_configuration

    with_synchronous_debug_sending do
      outcomes = [
        capture_exception_check,
        capture_message_check,
        capture_exception_with_info_check,
      ]
      outcomes.each { |o| @output.puts "#{o.sent ? 'OK  ' : 'FAIL'} #{o.check}" }
      outcomes.all?(&:sent)
    end
  end

  private

  def config
    Sentry.get_current_client.configuration
  end

  def report_configuration
    @output.puts "environment: #{config.environment.inspect} (enabled_environments: #{config.enabled_environments.inspect})"
    @output.puts "dsn host: #{config.dsn&.host.inspect}"
  end

  def with_synchronous_debug_sending
    original_threads = config.background_worker_threads
    original_debug = config.debug
    config.background_worker_threads = 0
    config.debug = true

    yield
  ensure
    config.background_worker_threads = original_threads
    config.debug = original_debug
  end

  def marker
    @marker ||= "SentryVerifier-#{SecureRandom.hex(4)}"
  end

  def capture_exception_check
    begin
      raise "#{marker}: simulated unhandled exception (capture_exception)"
    rescue StandardError => e
      result = Sentry.capture_exception(e)
    end
    Outcome.new(check: 'Sentry.capture_exception (simulates an unhandled 500)', sent: result.present?)
  end

  def capture_message_check
    result = Sentry.capture_message("#{marker}: test message (capture_message)")
    Outcome.new(check: 'Sentry.capture_message', sent: result.present?)
  end

  def capture_exception_with_info_check
    begin
      raise "#{marker}: simulated exception (capture_exception_with_info)"
    rescue StandardError => e
      result = Sentry.capture_exception_with_info(e, 'SentryVerifier check', marker: marker)
    end
    Outcome.new(check: 'Sentry.capture_exception_with_info', sent: result.present?)
  end
end
