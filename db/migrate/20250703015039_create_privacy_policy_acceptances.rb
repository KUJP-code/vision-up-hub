class CreatePrivacyPolicyAcceptances < ActiveRecord::Migration[7.1]
  def change
    create_table :privacy_policy_acceptances do |t|
      t.references :user,            null: false, foreign_key: true
      t.references :privacy_policy,  null: false, foreign_key: true
      t.datetime   :accepted_at,     null: false
      t.timestamps
    end

    add_index :privacy_policy_acceptances,
              %i[user_id privacy_policy_id],
              unique: true,
              name: "index_privacy_acceptances_on_user_and_policy"
  end
end
