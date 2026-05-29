# frozen_string_literal: true

class SimplifyTeacherToolsToOrgOwned < ActiveRecord::Migration[7.1]
  def up
    add_reference :teacher_tools, :organisation, foreign_key: true

    execute <<~SQL
      UPDATE teacher_tools
      SET organisation_id = organisation_teacher_tool_sets.organisation_id
      FROM organisation_teacher_tool_sets
      WHERE teacher_tools.teacher_tool_set_id = organisation_teacher_tool_sets.teacher_tool_set_id
        AND teacher_tools.organisation_id IS NULL
    SQL

    change_column_null :teacher_tools, :organisation_id, false

    remove_foreign_key :teacher_tools, :teacher_tool_sets if foreign_key_exists?(:teacher_tools, :teacher_tool_sets)
    remove_index :teacher_tools, :teacher_tool_set_id if index_exists?(:teacher_tools, :teacher_tool_set_id)
    remove_column :teacher_tools, :teacher_tool_set_id, :bigint

    drop_table :organisation_teacher_tool_overrides
    drop_table :organisation_teacher_tool_sets
    drop_table :teacher_tool_sets
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
