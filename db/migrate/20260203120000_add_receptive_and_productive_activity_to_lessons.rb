# frozen_string_literal: true

class AddReceptiveAndProductiveActivityToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :receptive_activity, :jsonb, default: []
    add_column :lessons, :productive_activity, :jsonb, default: []
  end
end
