class CreateOrganisationLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :organisation_lessons do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.date :event_date

      t.timestamps
    end
  end
end
