###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module HudDemographics
  extend ActiveSupport::Concern

  HUD_RACES = {
    am_ind_ak_native: 'American Indian, Alaska Native, or Indigenous',
    asian: 'Asian or Asian American',
    black_af_american: 'Black, African American, or African',
    native_hi_pacific: 'Native Hawaiian or Pacific Islander',
    white: 'White',
  }.freeze

  HUD_GENDERS = {
    female: 'Female',
    male: 'Male',
    no_single_gender: 'A gender other than singularly female or male (e.g., non-binary, genderfluid, agender, culturally specific gender)',
    transgender: 'Transgender',
    questioning: 'Questioning',
  }.freeze

  included do
    def gender_descriptions(brief: false)
      map = brief ? { **HUD_GENDERS, no_single_gender: 'Non-binary' } : HUD_GENDERS
      map.select { |k| send(k) }.values
    end

    def race_descriptions
      HUD_RACES.select { |k| send(k) }.values
    end

    def genders
      HUD_GENDERS.select { |k| send(k) }.keys
    end

    def races
      HUD_RACES.select { |k| send(k) }.keys
    end
  end
end
