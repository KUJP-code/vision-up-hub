# frozen_string_literal: true

class AddResourceDeletionsToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :resource_deletions, :jsonb, default: {}, null: false
  end
end
