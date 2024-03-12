class CreateSupportMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :support_messages do |t|
      t.string :message
      t.references :user, null: true, foreign_key: true
      t.references :support_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
