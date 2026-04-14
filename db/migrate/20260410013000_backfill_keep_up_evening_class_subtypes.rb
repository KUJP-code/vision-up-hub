# frozen_string_literal: true

class BackfillKeepUpEveningClassSubtypes < ActiveRecord::Migration[7.1]
  class MigrationLesson < ActiveRecord::Base
    self.table_name = 'lessons'
    self.inheritance_column = :_type_disabled
  end

  KEEP_UP_LEVELS = [11, 12].freeze
  TOPIC_STUDY_SUBTYPE = 6

  def up
    say_with_time 'Backfilling keep up EveningClass lessons without subtype to topic_study' do
      MigrationLesson
        .where(type: 'EveningClass', level: KEEP_UP_LEVELS, subtype: nil)
        .update_all(subtype: TOPIC_STUDY_SUBTYPE)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Cannot safely restore previous nil subtypes for keep up EveningClass records'
  end
end
