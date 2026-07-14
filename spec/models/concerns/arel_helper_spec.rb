###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression coverage for ArelHelper. Rails 8's Arel dropped the alias argument
# from Function/NamedFunction constructors; these examples exercise nf/cl/cast so a
# future Arel API change surfaces in CI instead of only at runtime (the helper had
# no spec coverage, which let a NamedFunction.new arity break reach a live report).
RSpec.describe ArelHelper do
  # ApplicationRecord includes ArelHelper, so any model exposes the class methods.
  let(:model) { Client }
  let(:table) { Client.arel_table }

  describe '.nf' do
    it 'builds a named function without an alias' do
      expect(model.nf('COUNT', [table[:id]]).to_sql).to eq('COUNT("clients"."id")')
    end

    it 'applies an alias via AS' do
      expect(model.nf('COUNT', [table[:id]], 'cnt').to_sql).to eq('COUNT("clients"."id") AS cnt')
    end

    it 'raises when args is not an Array' do
      expect { model.nf('COUNT', table[:id]) }.to raise_error(RuntimeError, 'args must be an Array')
    end
  end

  describe '.cl' do
    it 'builds a COALESCE function over its arguments' do
      expect(model.cl(table[:first_name], table[:last_name]).to_sql).
        to eq('COALESCE("clients"."first_name", "clients"."last_name")')
    end
  end

  describe '.cast' do
    it 'builds a CAST expression with the target type' do
      expect(model.cast(table[:id], 'text').to_sql).to eq('CAST("clients"."id" AS text)')
    end
  end
end
