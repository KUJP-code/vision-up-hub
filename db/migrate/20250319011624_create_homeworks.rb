class CreateHomeworks < ActiveRecord::Migration[7.1]
  def change
    create_table :homeworks do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.integer :week, null: false
      t.timestamps
    end
  end
end
