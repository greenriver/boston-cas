###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/util/sentry_verifier')

RSpec.describe SentryVerifier do
  subject(:verifier) { described_class.new(output: output) }

  let(:output) { StringIO.new }

  describe '#run!' do
    context 'when Sentry is not initialized' do
      before { allow(Sentry).to receive(:initialized?).and_return(false) }

      it 'returns false without sending any events' do
        expect(Sentry).not_to receive(:capture_exception)
        expect(Sentry).not_to receive(:capture_message)

        expect(verifier.run!).to eq(false)
      end
    end

    context 'when Sentry is initialized' do
      let(:sentry_configuration) { instance_double(Sentry::Configuration, environment: 'test', enabled_environments: ['test'], dsn: instance_double(Sentry::DSN, host: 'example.ingest.sentry.io'), background_worker_threads: 4, debug: false) }
      let(:sentry_client) { instance_double(Sentry::Client, configuration: sentry_configuration) }

      before do
        allow(Sentry).to receive(:initialized?).and_return(true)
        allow(Sentry).to receive(:get_current_client).and_return(sentry_client)
        allow(sentry_configuration).to receive(:background_worker_threads=)
        allow(sentry_configuration).to receive(:debug=)
      end

      it 'reports OK for each check when every capture call returns an event' do
        allow(Sentry).to receive(:capture_exception).and_return(instance_double(Sentry::ErrorEvent))
        allow(Sentry).to receive(:capture_message).and_return(instance_double(Sentry::ErrorEvent))
        allow(Sentry).to receive(:capture_exception_with_info).and_return(instance_double(Sentry::ErrorEvent))

        expect(verifier.run!).to eq(true)
        expect(output.string).to include('OK   Sentry.capture_exception')
        expect(output.string).to include('OK   Sentry.capture_message')
        expect(output.string).to include('OK   Sentry.capture_exception_with_info')
      end

      it 'reports FAIL and returns false for a check whose capture call returns nil (swallowed delivery failure)' do
        allow(Sentry).to receive(:capture_exception).and_return(nil)
        allow(Sentry).to receive(:capture_message).and_return(instance_double(Sentry::ErrorEvent))
        allow(Sentry).to receive(:capture_exception_with_info).and_return(instance_double(Sentry::ErrorEvent))

        expect(verifier.run!).to eq(false)
        expect(output.string).to include('FAIL Sentry.capture_exception')
        expect(output.string).to include('OK   Sentry.capture_message')
      end

      it 'sends synchronously with debug logging on, then restores the original config values' do
        allow(Sentry).to receive(:capture_exception).and_return(instance_double(Sentry::ErrorEvent))
        allow(Sentry).to receive(:capture_message).and_return(instance_double(Sentry::ErrorEvent))
        allow(Sentry).to receive(:capture_exception_with_info) do
          # Asserted mid-run, while the temporary values are still in effect -- a
          # post-hoc assertion after run! returns couldn't distinguish "never changed"
          # from "changed then restored".
          expect(sentry_configuration).to have_received(:background_worker_threads=).with(0)
          expect(sentry_configuration).to have_received(:debug=).with(true)
          instance_double(Sentry::ErrorEvent)
        end

        verifier.run!

        expect(sentry_configuration).to have_received(:background_worker_threads=).with(4)
        expect(sentry_configuration).to have_received(:debug=).with(false)
      end
    end
  end
end
