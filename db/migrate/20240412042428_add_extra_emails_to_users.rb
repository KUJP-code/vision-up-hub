class AddExtraEmailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :extra_emails, :jsonb, default: []
  end
end
