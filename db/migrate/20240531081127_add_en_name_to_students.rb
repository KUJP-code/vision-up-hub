class AddEnNameToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :en_name, :string, default: ''
  end
end
