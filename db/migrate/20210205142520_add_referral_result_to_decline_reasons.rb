class AddReferralResultToDeclineReasons < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decision_reasons, :referral_result, :integer
  end
end
