class CreateDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.string :user_agent
      t.string :platform
      t.string :ip_address
      t.integer :status, default: 0, null: false

      t.timestamps

      add_index :devices, [:user_id, :token], unique: true

    end
  end
end
