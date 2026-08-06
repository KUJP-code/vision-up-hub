# frozen_string_literal: true

class SplitLessonMaterials < ActiveRecord::Migration[7.1]
  def change
    rename_column :lessons, :materials, :purchase_materials
    add_column :lessons, :basic_materials, :jsonb, default: [], null: false
  end
end
