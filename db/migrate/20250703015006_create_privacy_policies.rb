class CreatePrivacyPolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :privacy_policies do |t|
      t.string :version
      t.text :content

      t.timestamps
    end
  end
end
