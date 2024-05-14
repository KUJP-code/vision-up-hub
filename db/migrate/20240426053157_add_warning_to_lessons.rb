class AddWarningToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :warning, :string, default: ''
  end
end
