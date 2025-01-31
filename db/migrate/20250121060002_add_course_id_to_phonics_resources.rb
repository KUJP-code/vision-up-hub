class AddCourseIdToPhonicsResources < ActiveRecord::Migration[7.1]
  def change
    add_reference :phonics_resources, :course, foreign_key: true, default: 1
  end
end
