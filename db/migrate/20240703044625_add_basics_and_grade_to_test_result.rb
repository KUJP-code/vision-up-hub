class AddBasicsAndGradeToTestResult < ActiveRecord::Migration[7.1]
  def change
    add_column :test_results, :basics, :integer, default: 0
    add_column :test_results, :grade, :string, default: ''
  end
end
