# frozen_string_literal: true

class MergeTutorialResourcesIntoCards < ActiveRecord::Migration[7.1]
  def up
    add_column :tutorial_categories, :items, :jsonb, null: false, default: []
    merge_items
    move_attachments
    drop_table :tutorial_resources
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Resource cards cannot be split back into categories and child resources'
  end

  private

  def merge_items
    category_ids = connection.select_values('SELECT id FROM tutorial_categories')
    category_ids.each do |category_id|
      resources = connection.select_all(<<~SQL.squish)
        SELECT items FROM tutorial_resources
        WHERE tutorial_category_id = #{connection.quote(category_id)}
        ORDER BY position, id
      SQL
      items = resources.flat_map { |resource| JSON.parse(resource['items']) }
      execute <<~SQL.squish
        UPDATE tutorial_categories
        SET items = #{connection.quote(items.to_json)}::jsonb
        WHERE id = #{connection.quote(category_id)}
      SQL
    end
  end

  def move_attachments
    execute <<~SQL.squish
      UPDATE active_storage_attachments AS attachments
      SET record_type = 'TutorialCategory',
          record_id = resources.tutorial_category_id
      FROM tutorial_resources AS resources
      WHERE attachments.record_type = 'TutorialResource'
        AND attachments.record_id = resources.id
        AND attachments.name = 'files'
    SQL
  end
end
