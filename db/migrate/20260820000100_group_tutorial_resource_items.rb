# frozen_string_literal: true

class GroupTutorialResourceItems < ActiveRecord::Migration[7.1]
  def up
    add_column :tutorial_resources, :items, :jsonb, null: false, default: []

    migrate_items
    remove_legacy_columns
    replace_display_index
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Grouped resource items cannot be split back into one resource per type'
  end

  private

  def migrate_items
    connection.select_all('SELECT id, kind, title, body, url FROM tutorial_resources').each do |row|
      items = item_for(row)
      execute <<~SQL.squish
        UPDATE tutorial_resources
        SET items = #{connection.quote(items.to_json)}::jsonb
        WHERE id = #{connection.quote(row['id'])}
      SQL
    end
  end

  def remove_legacy_columns
    change_table :tutorial_resources, bulk: true do |table|
      table.remove :kind, type: :string
      table.remove :body, type: :text
      table.remove :url, type: :string
    end
  end

  def replace_display_index
    remove_index :tutorial_resources, name: 'index_tutorial_resources_for_display', if_exists: true
    add_index :tutorial_resources, %i[tutorial_category_id position],
              name: 'index_tutorial_resources_for_display'
  end

  def item_for(row)
    return [] if row['kind'] == 'file'

    [{ kind: row['kind'], title: row['title'], body: row['body'], url: row['url'] }]
  end
end
