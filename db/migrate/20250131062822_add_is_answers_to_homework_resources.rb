class AddIsAnswersToHomeworkResources < ActiveRecord::Migration[7.0]
  def change
    add_column :homework_resources, :is_answers, :boolean, default: false, null: false
  end
end
