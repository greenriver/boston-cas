class CreateExternalReferrals < ActiveRecord::Migration[6.0]
  def change
    create_table :external_referrals do |t|
      t.references :client, null: false
      t.references :user, null: false
      t.date :referred_on, null: false

      t.timestamps null: false, index: true
      t.datetime :deleted_at
    end
  end
end
