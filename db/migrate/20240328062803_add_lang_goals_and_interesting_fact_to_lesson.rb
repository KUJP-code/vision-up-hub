class AddLangGoalsAndInterestingFactToLesson < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :lang_goals, :jsonb, default: {
      land: [],
      sky: [],
      galaxy: []
    }
    add_column :lessons, :interesting_fact, :string
  end
end
