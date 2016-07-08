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

      csv_text = File.read("#{Rails.root}/#{filename}")
      csv = CSV.parse(csv_text, headers: true)
      csv.each do |row|
        rules = Rule.where(type: "Rules::#{row['Class Name']}")
        rules.first_or_create! name: row['Rule Name'], verb: row['Verb']
      end

      final_count = Rule.count

      Rails.logger.info "Created #{final_count - initial_count} rules"
    end
    
  end
end