class CreateAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements do |t|
      t.text :message, null: false
      t.date :start_date, null: false
      t.date :finish_date, null: false
      t.string :link
      t.references :organisation, null: true, foreign_key: true
      t.integer :role, null: true
      
      t.timestamps
    end
  end
end
