class AddPriorityToSupportRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :support_requests, :priority, :integer, default: 0
  end
end
