# frozen_string_literal: true

class CreateSessionHandoffs < ActiveRecord::Migration[7.1]
  def change
    create_table :session_handoffs do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :destination_host, null: false
      t.string :state_digest, null: false
      t.string :token_digest, null: false
      t.string :authentication_digest, null: false
      t.datetime :expires_at, null: false
    end
    add_index :session_handoffs, :token_digest, unique: true
    add_index :session_handoffs, :expires_at
  end
end
