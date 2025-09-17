###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

namespace :db do
  namespace :schema do
    desc "Conditionally load the database schema"
    task :conditional_load, [] => [:environment] do |t, args|
      if ActiveRecord::Base.connection.tables.length == 0
        Rake::Task['db:schema:load'].invoke
      else
        puts "Refusing to load the database schema since there are tables present. This is not an error."
      end
    end
  end
end

# Start Monkey Patch for pg_dump 17.6
# Helper method to fix pg_dump 17.6 \restrict and \unrestrict commands
# Dynamically determines which structure file to fix based on the current database connection
def fix_pg_dump_restrict_commands
  return unless Rails.env.development? || Rails.env.test?

  [
    'structure.sql',
  ].each do |file_name|
    structure_file = Rails.root.join('db', file_name)
    next unless File.exist?(structure_file)

    schema = File.read(structure_file)
    next unless schema.match?(/^\\restrict|^\\unrestrict/)

    schema.gsub!(/^\\restrict/, '-- \restrict')
    schema.gsub!(/^\\unrestrict/, '-- \unrestrict')
    File.write(structure_file, schema)
  end
end

Rake::Task['db:schema:dump'].enhance do
  fix_pg_dump_restrict_commands
end

Rake::Task['db:migrate'].enhance do
  fix_pg_dump_restrict_commands
end

Rake::Task['db:schema:dump'].enhance do
  fix_pg_dump_restrict_commands
end
