# frozen_string_literal: true

class CreateTeacherTools < ActiveRecord::Migration[7.1]
  def change
    create_table :teacher_tool_sets do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :teacher_tool_sets, :slug, unique: true

    create_table :teacher_tools do |t|
      t.references :teacher_tool_set, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :kind, null: false, default: 0
      t.string :url, null: false
      t.string :embed_url
      t.string :duration_label
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    create_table :organisation_teacher_tool_sets do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :teacher_tool_set, null: false, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :organisation_teacher_tool_sets,
              [:organisation_id, :teacher_tool_set_id],
              unique: true,
              name: 'index_org_teacher_tool_sets_on_org_and_set'

    create_table :organisation_teacher_tool_overrides do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :teacher_tool, null: false, foreign_key: true
      t.integer :action, null: false, default: 0
      t.string :custom_title
      t.text :custom_description
      t.string :custom_url
      t.string :custom_embed_url
      t.integer :position_override
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :organisation_teacher_tool_overrides,
              [:organisation_id, :teacher_tool_id],
              unique: true,
              name: 'index_org_teacher_tool_overrides_on_org_and_tool'
  end
end
