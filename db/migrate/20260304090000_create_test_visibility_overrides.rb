# frozen_string_literal: true

class CreateTestVisibilityOverrides < ActiveRecord::Migration[7.1]
  def up
    create_table :test_visibility_overrides do |t|
      t.references :user, null: false, foreign_key: true
      t.references :test, null: false, foreign_key: true

      t.timestamps
    end

    add_index :test_visibility_overrides, %i[user_id test_id], unique: true

    return unless user_and_test_exist?

    execute <<~SQL.squish
      INSERT INTO test_visibility_overrides (user_id, test_id, created_at, updated_at)
      VALUES (5711, 28, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (user_id, test_id) DO NOTHING
    SQL
  end

  def down
    execute <<~SQL.squish
      DELETE FROM test_visibility_overrides
      WHERE user_id = 5711 AND test_id = 28
    SQL

    drop_table :test_visibility_overrides
  end

  private

  def user_and_test_exist?
    select_value('SELECT 1 FROM users WHERE id = 5711 LIMIT 1').present? &&
      select_value('SELECT 1 FROM tests WHERE id = 28 LIMIT 1').present?
  end
end
