class CreateCourseTests < ActiveRecord::Migration[7.1]
  def change
    create_table :course_tests do |t|
      t.references :course, null: false, foreign_key: true
      t.references :test, null: false, foreign_key: true
      t.integer :week

      t.timestamps
    end
  end
end
