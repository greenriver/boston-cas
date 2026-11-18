###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../config/deploy/docker/lib/cron_installer'

RSpec.describe CronInstaller do
  describe 'jitter' do
    let(:installer) { CronInstaller.new(:eks_mode) }
    let(:line) { "0 5 * * * /bin/bash -l -c 'cd /app && RAILS_ENV=production bundle exec rake cas:daily --silent ##interruptable=false##'" }

    it 'is the same for a schedule line on every deploy' do
      first = installer.send(:get_cron_expression, line, add_jitter: true)
      second = CronInstaller.new(:eks_mode).send(:get_cron_expression, line, add_jitter: true)

      expect(second).to eq(first)
    end

    it 'stays within the jitter window' do
      minute = installer.send(:get_cron_expression, line, add_jitter: true).split(' ').first.to_i

      expect(minute).to be_between(0, CronInstaller::AMOUNT_OF_JITTER_IN_MINUTES - 1)
    end
  end

  describe 'installing cronjobs without deleting retained Jobs' do
    let(:crons) { double('crons') }
    let(:vpas) { double('vpas') }
    let(:template) do
      <<~YAML
        kind: CronJob
        metadata:
          name: <%= jobname %>
          labels:
            cron-source: rails
          annotations:
            description: <%= description %>
        spec:
          schedule: "<%= schedule_expression %>"
      YAML
    end
    let(:cronjob) { Cronjob.new(description: 'rake some:task', schedule_expression: '5 * * * *', command: ['rake', 'some:task']) }

    before do
      allow(cronjob).to receive(:crons).and_return(crons)
      allow(cronjob).to receive(:vpas).and_return(vpas)
      allow(cronjob).to receive(:configmap).and_return(double(data: { 'cronjob.yaml' => template }))
    end

    it 'creates a cronjob and VPA that are not in the cluster yet' do
      expect(crons).to receive(:create_resource)
      expect(crons).not_to receive(:json_patch)
      expect(cronjob).to receive(:create_vpa!)

      cronjob.run!(existing_crons: Set.new, existing_vpas: Set.new)
    end

    it 'patches an existing cronjob in place instead of recreating it' do
      expect(crons).not_to receive(:create_resource)
      expect(crons).to receive(:json_patch) do |name, ops|
        expect(name).to eq(cronjob.jobname)
        expect(ops).to include({ op: 'replace', path: '/spec', value: { 'schedule' => '5 * * * *' } })
      end
      expect(crons).not_to receive(:delete_resource)
      expect(cronjob).to receive(:update_vpa!)

      cronjob.run!(existing_crons: Set[cronjob.jobname], existing_vpas: Set["cronjob-#{cronjob.jobname}"])
    end

    it 'deletes only cronjobs that are no longer scheduled' do
      kept = K8s::Resource.new(metadata: { name: 'kept', namespace: 'ns' })
      defunct = K8s::Resource.new(metadata: { name: 'defunct', namespace: 'ns' })
      allow(cronjob).to receive(:cron_list).and_return([kept, defunct])

      expect(crons).to receive(:delete_resource).with(defunct)
      expect(crons).not_to receive(:delete_resource).with(kept)

      cronjob.clear_defunct!(['kept'])
    end

    it 'deletes only orphaned VPAs' do
      kept = K8s::Resource.new(metadata: { name: 'cronjob-kept', labels: { 'cronjob-name' => 'kept' } })
      orphan = K8s::Resource.new(metadata: { name: 'cronjob-gone', labels: { 'cronjob-name' => 'gone' } })
      allow(cronjob).to receive(:cron_list).and_return([K8s::Resource.new(metadata: { name: 'kept' })])
      allow(cronjob).to receive(:vpa_list).and_return([kept, orphan])

      expect(vpas).to receive(:delete_resource).with(orphan)
      expect(vpas).not_to receive(:delete_resource).with(kept)

      cronjob.clear_defunct_vpas!
    end

    it 'lists existing resources once and deletes only defunct cronjobs' do
      existing_crons = Set['a-task']
      existing_vpas = Set['cronjob-a-task']
      allow(Cronjob).to receive(:existing_cron_names).and_return(existing_crons)
      allow(Cronjob).to receive(:existing_vpa_names).and_return(existing_vpas)
      installer = CronInstaller.new(:eks_mode)
      allow(installer).to receive(:each_cron_entry).
        and_yield('5 * * * *', ['rake', 'a:task', '##interruptable=true##']).
        and_yield('6 * * * *', ['rake', 'b:task', '##interruptable=false##'])
      run_args = []
      allow_any_instance_of(Cronjob).to receive(:run!) { |_cronjob, **kwargs| run_args << kwargs }
      allow(Cronjob).to receive(:clear_defunct_vpas!)

      expect(Cronjob).to receive(:clear_defunct!).with(['a-task', 'b-task'])

      installer.run!

      expect(Cronjob).to have_received(:existing_cron_names).once
      expect(run_args).to eq([{ existing_crons: existing_crons, existing_vpas: existing_vpas }] * 2)
    end

    it 'refuses two schedule entries that map to the same cronjob name' do
      allow(Cronjob).to receive(:existing_cron_names).and_return(Set.new)
      allow(Cronjob).to receive(:existing_vpa_names).and_return(Set.new)
      installer = CronInstaller.new(:eks_mode)
      allow(installer).to receive(:each_cron_entry).
        and_yield('5 * * * *', ['rake', 'a:task', '##interruptable=true##']).
        and_yield('6 * * * *', ['rake', 'a:task', '##interruptable=true##'])
      allow_any_instance_of(Cronjob).to receive(:run!)

      expect(Cronjob).not_to receive(:clear_defunct!)
      expect { installer.run! }.to raise_error(/both map to cronjob name/)
    end
  end
end
