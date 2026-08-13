###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe '.permissions_with_descriptions' do
    it 'covers every permission in Role.permissions' do
      missing = Role.permissions - Role.permissions_with_descriptions.keys
      expect(missing).to be_empty, "Missing metadata for: #{missing.join(', ')}"
    end

    it 'has required keys on every entry' do
      Role.permissions_with_descriptions.each do |perm, meta|
        expect(meta).to have_key(:description), "#{perm} missing :description"
        expect(meta).to have_key(:category), "#{perm} missing :category"
        expect(meta).to have_key(:sub_category), "#{perm} missing :sub_category"
        expect(meta).to have_key(:administrative), "#{perm} missing :administrative"
      end
    end
  end

  describe '.permissions_by_group' do
    it 'returns a nested hash of category > sub_category > array' do
      groups = Role.permissions_by_group
      expect(groups).to be_a(Hash)
      groups.each do |_category, subs|
        expect(subs).to be_a(Hash)
        subs.each do |_sub, perms|
          expect(perms).to be_an(Array)
          expect(perms.first).to have_key(:name)
        end
      end
    end
  end

  it 'administrative flag in permissions_with_descriptions matches administrative_permissions' do
    admin_set = Role.administrative_permissions.to_set
    Role.permissions_with_descriptions.each do |perm, meta|
      if admin_set.include?(perm)
        expect(meta[:administrative]).to be(true), ":#{perm} is in administrative_permissions but administrative: false in metadata"
      else
        expect(meta[:administrative]).to be(false), ":#{perm} is not in administrative_permissions but administrative: true in metadata"
      end
    end
  end
end
