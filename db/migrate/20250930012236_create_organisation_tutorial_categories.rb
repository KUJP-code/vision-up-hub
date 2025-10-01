class CreateOrganisationTutorialCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :organisation_tutorial_categories do |t|
      t.references :organisation, null: false,
                                  foreign_key: { on_delete: :cascade }
      t.references :tutorial_category, null: false,
                                       foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :organisation_tutorial_categories,
              [:organisation_id, :tutorial_category_id],
              unique: true,
              name: "index_org_tutorial_categories_on_org_and_category"
  end
end
