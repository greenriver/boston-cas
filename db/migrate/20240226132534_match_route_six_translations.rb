class MatchRouteSixTranslations < ActiveRecord::Migration[6.1]
  def up
    translations_six.each do |k, v|
      Translation.create!(
        key: k,
        text: v,
      )
    end
  end 
  def down
    Translation.where(key: translations_six.keys).destroy_all
  end
  private
    def translations_six = {
      'Shelter Agency Six' => 'Shelter Agency',
      'HSA Six' => 'HSA',
      'Housing Subsidy Administrator Six' => 'Housing Subsidy Administrator',
      'HSA Complete Match Six' => 'HSA Complete Match',
      'CoC Six' => 'DND',
      'Confirm Match Success Six' => 'Confirm Match Success',
      'case worker six' => 'case worker',
      'View details here: Six' => 'Your client has matched to a vacancy in a housing navigation program. Please connect with housing navigation program staff to discuss this opportunity with the client. You should not accept or decline the opportunity in the CAS system prior to the client discussing the opportunity with housing navigation program staff:',
    }
end
