###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Reporting
  class FilterBase < ::ModelForm
    include Reporting::FilterScopes

    attribute :start, Date, lazy: true, default: ->(r, _) { r.default_start }
    attribute :end, Date, lazy: true, default: ->(r, _) { r.default_end }
    attribute :match_route, Integer
    attribute :match_routes, Array, default: []
    attribute :program_types, Array, default: []
    attribute :agencies, Array, default: []
    attribute :household_types, Array, default: []
    attribute :veteran_statuses, Array, default: []
    attribute :age_ranges, Array, default: []
    attribute :genders, Array, default: []
    attribute :races, Array, default: []
    attribute :ethnicities, Array, default: []
    attribute :disabilities, Array, default: []
    attribute :cohort_ids, Array, default: []
    attribute :contacts, Array, default: []
    attribute :contact_type, Integer

    # Defaults
    attribute :default_start, Date, default: (Date.current - 1.year).beginning_of_year
    attribute :default_end, Date, default: (Date.current - 1.year).end_of_year

    def cache_key
      to_h
    end

    # use incoming data, if not available, use previously set value, or default value
    def update(filters) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return self unless filters.present?

      filters = filters.to_h.with_indifferent_access

      self.start = filters.dig(:start)&.to_date || start
      self.end = filters.dig(:end)&.to_date || self.end
      self.match_routes = Array.wrap(filters.dig(:match_route).to_i) if filters.dig(:match_route).present?
      self.match_routes = filters.dig(:match_routes)&.reject(&:blank?)&.map(&:to_i).presence || match_routes
      self.program_types = filters.dig(:program_types)&.reject(&:blank?).presence || program_types
      self.agencies = filters.dig(:agencies)&.reject(&:blank?)&.map(&:to_i).presence || agencies
      self.household_types = filters.dig(:household_types)&.reject(&:blank?)&.map(&:to_sym).presence || household_types
      self.veteran_statuses = filters.dig(:veteran_statuses)&.reject(&:blank?)&.map(&:to_sym).presence || veteran_statuses
      self.age_ranges = filters.dig(:age_ranges)&.reject(&:blank?)&.map(&:to_sym).presence || age_ranges
      self.genders = filters.dig(:genders)&.reject(&:blank?)&.map(&:to_sym).presence || genders
      self.races = filters.dig(:races)&.reject(&:blank?)&.map(&:to_sym).presence || races
      self.ethnicities = filters.dig(:ethnicities)&.reject(&:blank?)&.map(&:to_sym).presence || ethnicities
      self.disabilities = filters.dig(:disabilities)&.reject(&:blank?)&.map(&:to_sym).presence || disabilities
      self.cohort_ids = filters.dig(:cohort_ids)&.reject(&:blank?)&.map(&:to_sym).presence || cohort_ids
      self.contacts = filters.dig(:contacts)&.reject(&:blank?)&.map(&:to_sym).presence || contacts
      self.contact_type = filters.dig(:contact_type)&.presence || contact_type

      ensure_date_order if valid?
      self
    end

    def apply(scope)
      @filter = self
      scope = filter_for_range(scope)
      scope = filter_for_match_routes(scope)
      scope = filter_for_program_types(scope)
      scope = filter_for_agencies(scope)
      scope = filter_for_household_types(scope)
      scope = filter_for_veteran_statuses(scope)
      scope = filter_for_age_ranges(scope)
      scope = filter_for_genders(scope)
      scope = filter_for_races(scope)
      scope = filter_for_ethnicities(scope)
      scope = filter_for_disabilities(scope)
      scope = filter_for_cohorts(scope)
      scope = filter_for_contacts(scope)
      scope = filter_for_contact_type(scope)

      scope
    end

    def for_params
      {
        filters: {
          # NOTE: order specified here is used to echo selections in describe_filter
          start: start,
          end: self.end,
          match_routes: match_routes,
          program_types: program_types,
          agencies: agencies,
          household_types: household_types,
          veteran_statuses: veteran_statuses,
          age_ranges: age_ranges,
          genders: genders,
          races: races,
          ethnicities: ethnicities,
          disabilities: disabilities,
          contacts: contacts,
          contact_type: contact_type,
        },
      }
    end

    def to_h
      for_params[:filters]
    end
    alias inspect to_h

    def known_params
      @known_params ||= [
        :start,
        :end,
        :match_route,
        :contact_type,
        match_routes: [],
        program_types: [],
        agencies: [],
        household_types: [],
        veteran_statuses: [],
        age_ranges: [],
        genders: [],
        races: [],
        ethnicities: [],
        disabilities: [],
        cohort_ids: [],
        contacts: [],
      ].freeze
    end

    def match_route_options_for_select
      MatchRoutes::Base.active.map do |route|
        [
          Translation.translate(route.title),
          route.id,
        ]
      end.to_h
    end

    def program_type_options_for_select
      SubProgram.types.map do |type|
        [
          type[:label],
          type[:value],
        ]
      end.to_h
    end

    def agency_options_for_select
      Agency.order(name: :asc).pluck(:name, :id).to_h
    end

    def household_type_options_for_select
      {
        individual: 'Individual',
        individual_adult: 'Individual Adult',
        individual_child: 'Individual Child',
        adult_and_child: 'Adult and Child',
        parenting_youth: 'Parenting Youth',
      }.invert
    end

    def veteran_status_options_for_select
      {
        non_veteran: 'Non-veteran',
        veteran: 'Veteran',
      }.invert
    end

    def gender_options_for_select
      {
        female: 'Female',
        male: 'Male',
        no_single_gender: 'A gender other than singularly female or male (e.g., non-binary, genderfluid, agender, culturally specific gender)',
        transgender: 'Transgender',
        questioning: 'Questioning',
      }.invert
    end

    def age_range_options_for_select
      {
        under_eighteen: '< 18',
        eighteen_to_twenty_four: '18 - 24',
        twenty_five_to_twenty_nine: '25 - 29',
        thirty_to_thirty_nine: '30 - 39',
        forty_to_forty_nine: '40 - 49',
        fifty_to_fifty_four: '50 - 54',
        fifty_five_to_fifty_nine: '55 - 59',
        sixty_to_sixty_one: '60 - 61',
        over_sixty_one: '62+',
      }.invert
    end

    def race_options_for_select
      {
        am_ind_ak_native: 'American Indian, Alaska Native, or Indigenous',
        asian: 'Asian or Asian American',
        black_af_american: 'Black, African American, or African',
        native_hi_pacific: 'Native Hawaiian or Pacific Islander',
        white: 'White',
      }.invert
    end

    def ethnicity_options_for_select
      {
        non_hispanic: 'Non-Hispanic/Non-Latin(a)(o)(x)',
        hispanic: 'Hispanic/Latin(a)(o)(x)',
      }.invert
    end

    def disability_options_for_select
      {
        hiv_aids: 'HIV/AIDS',
        chronic_health_problem: 'Chronic Health Problem',
        mental_health_problem: 'Mental Health Problem',
        substance_abuse_problem: 'Substance Abuse Problem',
        developmental_disability: 'Developmental Disability',
        physical_disability: 'Physical Disability',
        disabling_condition: 'Disabling Condition',
        disability_verified_on: 'Verified Disability',
      }.invert
    end

    def cohort_options_for_select
      Warehouse::Cohort.visible_in_cas.pluck(:name, :id).to_h
    end

    def selected_params_for_display
      {}.tap do |opts|
        opts['Report Range'] = date_range_words
        opts['Match Routes'] = match_route_names
        opts['Program Types'] = program_type_names
        opts['Agencies'] = agency_names
        opts['Household Types'] = household_type_names
        opts['Veteran Status'] = veteran_status_names
        opts['Age Ranges'] = age_range_names
        opts['Genders'] = gender_names
        opts['Races'] = race_names
        opts['Ethnicities'] = ethnicity_names
        opts['Disabilities'] = disability_names
        opts['Cohorts'] = cohort_names
      end
    end

    def contact_options_for_select
      Contact.active_contacts.map do |contact|
        [
          contact.name,
          contact.id,
        ]
      end.to_h
    end

    def contact_type_options_for_select
      MatchContacts.input_names.map do |contact_type|
        [
          Contact.label_for(contact_type)&.gsub('Contacts', 'Contact'),
          contact_type,
        ]
      end.to_h
    end

    def describe_filter(keys = nil)
      [].tap do |descriptions|
        # only show "on" if explicitly chosen
        display_keys = for_params[:filters]
        display_keys.each_key do |key|
          next if keys.present? && ! keys.include?(key)

          descriptions << describe(key)
        end
      end.compact
    end

    def describe_filter_as_html(keys = nil, limited: true, inline: false)
      describe_filter(keys).uniq.map do |(k, v)|
        wrapper_classes = ['report-parameters__parameter']
        label_text = k
        if inline
          wrapper_classes << 'd-flex'
          label_text += ':'
        end
        content_tag(:div, class: wrapper_classes) do
          label = content_tag(:label, label_text, class: 'label label-default parameter-label')
          if v.is_a?(Array)
            if limited
              count = v.count
              v = v.first(5)
              v << "#{count - 5} more" if count > 5
            end
            v = v.to_sentence
          end
          value_classes = ['label', 'label-primary', 'parameter-value']
          value_classes << 'pl-0' if inline
          label.concat(content_tag(:label, v, class: value_classes))
        end
      end.join.html_safe
    end

    def range
      start .. self.end
    end

    private def ensure_date_order
      return if start < self.end

      self.start, self.end = self.end, start
    end

    private def date_range_words
      "#{start} - #{self.end}"
    end

    private def describe(key, value = chosen(key))
      title = case key
      when :start
        'Report Range'
      when :end
        nil
      else
        key.to_s.titleize
      end

      return unless value.present?

      [title, value]
    end

    private def chosen(key)
      case key
      when :start
        date_range_words
      when :end
        nil
      when :match_routes
        match_route_names
      when :program_types
        program_type_names
      when :agencies
        agency_names
      when :household_types
        household_type_names
      when :veteran_statuses
        veteran_status_names
      when :age_ranges
        age_range_names
      when :genders
        gender_names
      when :races
        race_names
      when :ethnicities
        ethnicity_names
      when :disabilities
        disability_names
      when :cohort_ids
        cohort_names
      end
    end

    private def match_route_names
      match_route_options_for_select.invert.select { |k, _| match_routes.include?(k) }.values
    end

    private def program_type_names
      program_type_options_for_select.invert.select { |k, _| program_types.include?(k) }.values
    end

    private def agency_names
      agency_name_options_for_select.invert.select { |k, _| agency_names.include?(k) }.values
    end

    private def household_type_names
      household_type_name_options_for_select.invert.select { |k, _| household_types.include?(k) }.values
    end

    private def veteran_status_names
      veteran_status_name_options_for_select.invert.select { |k, _| veteran_statuses.include?(k) }.values
    end

    private def age_range_names
      age_range_name_options_for_select.invert.select { |k, _| age_ranges.include?(k) }.values
    end

    private def race_names
      race_name_options_for_select.invert.select { |k, _| races.include?(k) }.values
    end

    private def ethnicity_names
      ethnicity_name_options_for_select.invert.select { |k, _| ethnicities?(k) }.values
    end

    private def disability_names
      disability_name_options_for_select.invert.select { |k, _| disabilities(k) }.values
    end

    private def cohort_names
      cohort_options_for_select.invert.select { |k, _| cohort_ids.include?(k) }.values
    end
  end
end
