class CreateAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements do |t|
      t.text :message, null: false
      t.date :valid_from, null: false
      t.date :valid_until, null: false
      t.string :link

      t.timestamps
    end
  end
end
