class MatchRouteElevenTranslations < ActiveRecord::Migration[7.0]
  def up
    translations_eleven.each do |k, v|
      Translation.create!(
        key: k,
        text: v,
      )
    end
  end

  def down
    Translation.where(key: translations_eleven.keys).destroy_all
  end

  private

  def translations_eleven = {
    'Match Route Eleven' => 'Match Route Eleven',
    'SSP Eleven' => 'SSP',
    'Shelter Agency Eleven' => 'Shelter Agency',
    'HSA Eleven' => 'HSA',
    'Housing Search Provider Eleven' => 'Housing Search Provider',
    'Housing Subsidy Administrator Eleven' => 'Housing Subsidy Administrator',
    'Stabilization Service Provider Eleven' => 'Stabilization Services Provider',
    'Stabilization Services Provider Eleven' => 'Stabilization Services Provider',
    'CoC Eleven' => 'DND',
  }
end
