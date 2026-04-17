# frozen_string_literal: true

class AddVideoPathsToTeacherTools < ActiveRecord::Migration[7.1]
  def up
    add_column :teacher_tools, :video_paths, :jsonb, default: [], null: false

    execute <<~SQL
      UPDATE teacher_tools
      SET video_paths = jsonb_build_array(embed_url)
      WHERE embed_url IS NOT NULL AND embed_url <> ''
    SQL
  end

  def down
    remove_column :teacher_tools, :video_paths
  end
end
