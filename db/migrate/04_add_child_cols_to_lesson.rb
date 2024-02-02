class AddChildColsToLesson < ActiveRecord::Migration[7.1]
  def change
    change_table :lessons do |t|
      t.jsonb :add_difficulty, default: []
      t.jsonb :example_sentences, default: []
      t.jsonb :extra_fun, default: []
      t.jsonb :instructions, default: []
      t.jsonb :large_groups, default: []
      t.jsonb :links, default: {}
      t.jsonb :materials, default: []
      t.jsonb :notes, default: []
      t.jsonb :outro, default: []
      t.jsonb :steps, default: []
      t.integer :subtype
      t.string :topic
      t.jsonb :vocab, default: []
      t.jsonb :intro, default: []
    end
  end
end
