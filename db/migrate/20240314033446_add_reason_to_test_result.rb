class AddReasonToTestResult < ActiveRecord::Migration[7.1]
  def change
    add_column :test_results, :reason, :string
  end
end
