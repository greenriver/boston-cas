###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'csv'

if Rails.env.development? || Rails.env.test?
  Dir.glob("#{Rails.root.join('app', 'models', 'rules')}/*.rb").each do |rule_subclass_file|
    require_dependency rule_subclass_file
  end
end

module CasSeeds
  class Rules
    def run!
      filename = 'db/rules.csv'

      initial_count = Rule.count
      incoming_rules = []

      csv_text = File.read("#{Rails.root}/#{filename}")
      csv = CSV.parse(csv_text, headers: true)
      csv.each do |row|
        incoming_rules << "Rules::#{row['Class Name']}"
        rules = Rule.where(type: "Rules::#{row['Class Name']}")
        rule = rules.first_or_create! name: row['Rule Name'], verb: row['Verb']
        rule.update(name: row['Rule Name'], alternate_name: row['Alternate Name'], verb: row['Verb'])
      end
      final_count = Rule.count
      Rails.logger.info "Created #{final_count - initial_count} rules"

      # remove any rules not in the file
      remove_rule_ids = Rule.where.not(type: incoming_rules).pluck(:id)
      removed_requirements = Requirement.where(rule_id: remove_rule_ids).destroy_all
      Rails.logger.info "Removed #{removed_requirements.count} requirements"

      Rule.where(id: remove_rule_ids).destroy_all

      Rails.logger.info "Removed #{remove_rule_ids.count} rules"
    end

  end
end
