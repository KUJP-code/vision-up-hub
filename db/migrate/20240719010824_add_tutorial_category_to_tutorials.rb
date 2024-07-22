class AddTutorialCategoryToTutorials < ActiveRecord::Migration[7.1]
  def change
    add_reference :pdf_tutorials, :tutorial_category, null: false, foreign_key: true
    add_reference :faq_tutorials, :tutorial_category, null: false, foreign_key: true
    add_reference :video_tutorials, :tutorial_category, null: false, foreign_key: true
  end
end
