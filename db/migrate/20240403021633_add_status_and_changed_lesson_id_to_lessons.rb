class AddStatusAndChangedLessonIdToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :status, :integer
    add_column :lessons, :changed_lesson_id, :integer

    add_foreign_key :lessons, :lessons, column: :changed_lesson_id
  end
end
