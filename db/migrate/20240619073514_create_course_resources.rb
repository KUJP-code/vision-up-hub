class CreateCourseResources < ActiveRecord::Migration[7.1]
  def change
    create_table :course_resources do |t|
      t.references :course, null: false, foreign_key: true
      t.references :category_resource, null: false, foreign_key: true

      t.timestamps
    end
  end
end
