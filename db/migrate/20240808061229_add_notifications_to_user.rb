class AddNotificationsToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :notifications, :jsonb, default: []
  end
end
