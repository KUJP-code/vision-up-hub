class AddReviewToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :review, :jsonb, default: [], null: false
  end
end
