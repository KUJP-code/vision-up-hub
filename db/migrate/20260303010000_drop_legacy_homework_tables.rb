# frozen_string_literal: true

class DropLegacyHomeworkTables < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL.squish
      DELETE FROM active_storage_attachments
      WHERE record_type = 'Homework'
    SQL

    drop_table :homework_resources, if_exists: true
    drop_table :homeworks, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Legacy homework tables were removed'
  end
end
