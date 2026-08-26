# frozen_string_literal: true

class ConsolidateTutorialResources < ActiveRecord::Migration[7.1]
  def up
    create_section_schema
    create_resource_schema
    migrate_tutorials
    drop_legacy_tables
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'The legacy tutorial tables were consolidated into tutorial_resources'
  end

  private

  def create_section_schema
    create_table :tutorial_sections do |t|
      t.string :title, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :tutorial_sections, :title, unique: true

    add_reference :tutorial_categories, :tutorial_section,
                  null: true, foreign_key: { on_delete: :nullify }
    add_column :tutorial_categories, :position, :integer, null: false, default: 0
  end

  def create_resource_schema
    create_table :tutorial_resources do |t|
      t.references :tutorial_category, null: false, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false
      t.string :title, null: false
      t.text :body
      t.string :url
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :tutorial_resources, %i[tutorial_category_id kind position],
              name: 'index_tutorial_resources_for_display'
  end

  def migrate_tutorials
    migrate_file_tutorials
    migrate_video_tutorials
    migrate_faq_tutorials
  end

  def migrate_file_tutorials
    connection.select_all('SELECT * FROM pdf_tutorials ORDER BY id').each do |row|
      resource_id = insert_resource(row, kind: 'file', title: row['title'])
      execute <<~SQL.squish
        UPDATE active_storage_attachments
        SET record_type = 'TutorialResource', record_id = #{resource_id}, name = 'files'
        WHERE record_type = 'PdfTutorial' AND record_id = #{connection.quote(row['id'])} AND name = 'file'
      SQL
    end
  end

  def migrate_video_tutorials
    connection.select_all('SELECT * FROM video_tutorials ORDER BY id').each do |row|
      insert_resource(row, kind: 'video', title: row['title'], url: row['video_path'])
    end
  end

  def migrate_faq_tutorials
    connection.select_all('SELECT * FROM faq_tutorials ORDER BY id').each do |row|
      insert_resource(row, kind: 'faq', title: row['question'], body: row['answer'])
    end
  end

  def drop_legacy_tables
    drop_table :faq_tutorials
    drop_table :video_tutorials
    drop_table :pdf_tutorials
  end

  def insert_resource(row, kind:, title:, body: nil, url: nil)
    values = [row['tutorial_category_id'], kind, title, body, url, row['created_at'], row['updated_at']]
             .map { |value| connection.quote(value) }
    connection.select_value <<~SQL.squish
      INSERT INTO tutorial_resources
        (tutorial_category_id, kind, title, body, url, position, created_at, updated_at)
      VALUES (#{values[0]}, #{values[1]}, #{values[2]}, #{values[3]}, #{values[4]}, 0, #{values[5]}, #{values[6]})
      RETURNING id
    SQL
  end
end
