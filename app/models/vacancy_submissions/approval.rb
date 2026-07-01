###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module VacancySubmissions
  # Materializes an approved VacancySubmission's draft_data into real
  # Voucher/Opportunity/Requirement records.
  class Approval
    def initialize(vacancy_submission, user:)
      @vacancy_submission = vacancy_submission
      @user = user
    end

    def call!
      sub_program = resolve_sub_program!

      Array(vacancy_submission.units).each do |unit_hash|
        if sub_program.has_buildings?
          unit = build_unit_for(unit_hash)
          create_voucher!(sub_program, unit_hash, unit: unit)
          next
        end

        create_voucher!(sub_program, unit_hash)
      end
    end

    private

    attr_reader :vacancy_submission, :user

    def resolve_sub_program!
      program = Program.find_by(id: vacancy_submission.program_id)
      sub_program = program&.sub_programs&.find_by(id: vacancy_submission.sub_program_id)
      return sub_program if sub_program.present?

      vacancy_submission.errors.add(:sub_program_id, 'could not be resolved to a Sub-Program')
      raise ActiveRecord::RecordInvalid.new(vacancy_submission)
    end

    def create_voucher!(sub_program, unit_hash, unit: nil)
      voucher = Voucher.create!(
        sub_program: sub_program,
        creator: user,
        unit: unit,
        available: false,
        date_available: resolved_date(unit_hash),
      )
      voucher.create_opportunity!(available: false, available_candidate: false)
      attach_requirements!(unit || voucher, unit_hash)
    end

    def resolve_building_for(unit_hash)
      Building.find_or_create_by!(
        address: unit_hash['street'],
        city: unit_hash['city'],
        state: unit_hash['state'],
        zip_code: unit_hash['zip'],
      ) { |b| b.name = unit_hash['street'] }
    end

    def build_unit_for(unit_hash)
      building = resolve_building_for(unit_hash)
      unit = Unit.create!(
        building: building,
        name: unit_hash['unit_number'].presence || SecureRandom.hex,
        available: true,
        elevator_accessible: elevator_accessible?(unit_hash),
        notes: unit_hash['notes'],
      )
      attach_accessibility_requirements!(unit, unit_hash)
      attach_bedroom_requirement!(unit, unit_hash)
      attach_age_limit_requirement!(unit, unit_hash)
      attach_value_less_housing_attributes!(unit, unit_hash['shared_spaces'])
      attach_value_less_housing_attributes!(unit, unit_hash['amenities'])
      attach_attributes!(unit, unit_hash)
      attach_media_links!(unit, unit_hash)
      unit
    end

    def elevator_accessible?(unit_hash)
      Array(unit_hash['accessibility']).any? { |opt| VacancySubmission::ACCESSIBILITY_OPTIONS[opt] == Rules::Elevator }
    end

    def attach_accessibility_requirements!(unit, unit_hash)
      rule_classes = Array(unit_hash['accessibility']).map { |opt| VacancySubmission::ACCESSIBILITY_OPTIONS[opt] }.compact.uniq
      rule_classes.each do |rule_class|
        Requirement.create!(requirer: unit, rule: Rule.find_by(type: rule_class.name), positive: true)
      end
    end

    def attach_bedroom_requirement!(unit, unit_hash)
      mapping = VacancySubmission::BEDROOM_OPTIONS[unit_hash['bedrooms']]
      return if mapping.nil?

      Requirement.create!(
        requirer: unit,
        rule: Rule.find_by(type: mapping[:rule_class].name),
        positive: true,
        variable: mapping[:variable],
      )
    end

    def attach_age_limit_requirement!(unit, unit_hash)
      rule_class = VacancySubmission::AGE_LIMIT_OPTIONS[unit_hash['age_limit']]
      return if rule_class.nil?

      Requirement.create!(requirer: unit, rule: Rule.find_by(type: rule_class.name), positive: true)
    end

    def attach_value_less_housing_attributes!(unit, names)
      Array(names).each do |name|
        HousingAttribute.create!(housingable: unit, name: name, include_value: false)
      end
    end

    def attach_attributes!(unit, unit_hash)
      Array(unit_hash['attributes']).each do |attribute|
        next if attribute['name'].blank? || attribute['value'].blank?

        HousingAttribute.create!(housingable: unit, name: attribute['name'], value: attribute['value'], include_value: true)
      end
    end

    def attach_media_links!(unit, unit_hash)
      Array(unit_hash['media_links']).each do |media_link|
        next if media_link['url'].blank?

        HousingMediaLink.create!(housingable: unit, url: media_link['url'], label: media_link['label'].presence || 'Photo')
      end
    end

    def attach_requirements!(requirer, unit_hash)
      Array(unit_hash['requirements']).each do |requirement_attrs|
        next if requirement_attrs['rule_id'].blank?

        Requirement.create!(
          requirer: requirer,
          rule_id: requirement_attrs['rule_id'],
          positive: requirement_attrs['positive'].to_s != 'false',
          variable: requirement_attrs['variable'],
        )
      end
    end

    def resolved_date(unit_hash)
      unit_hash['date_ready'].present? ? Date.parse(unit_hash['date_ready']) : Date.current
    end
  end
end
