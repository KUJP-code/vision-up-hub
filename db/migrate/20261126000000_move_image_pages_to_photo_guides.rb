# frozen_string_literal: true

# Photo guides went from a single upload (image_page) to many (photo_guides).
# Lessons are STI, so their attachments are stored with record_type 'Lesson'.
class MoveImagePagesToPhotoGuides < ActiveRecord::Migration[7.1]
  def up
    rename_attachments from: 'image_page', to: 'photo_guides'
  end

  def down
    rename_attachments from: 'photo_guides', to: 'image_page'
  end

  private

  def rename_attachments(from:, to:)
    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET name = #{quote(to)}
      WHERE name = #{quote(from)} AND record_type = 'Lesson'
    SQL
  end

  def quote(value)
    connection.quote(value)
  end
end
