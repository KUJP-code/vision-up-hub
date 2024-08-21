class CreateFormTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :form_templates do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.jsonb :fields

      t.timestamps
    end
  end
end
