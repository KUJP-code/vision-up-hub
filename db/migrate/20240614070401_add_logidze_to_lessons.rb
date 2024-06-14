class AddLogidzeToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :log_data, :jsonb

    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE TRIGGER "logidze_on_lessons"
          BEFORE UPDATE OR INSERT ON "lessons" FOR EACH ROW
          WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
          -- Parameters: history_size_limit (integer), timestamp_column (text), filtered_columns (text[]),
          -- include_columns (boolean), debounce_time_ms (integer)
          EXECUTE PROCEDURE logidze_logger(2, 'updated_at', '{updated_at}');

        SQL
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS "logidze_on_lessons" on "lessons";
        SQL
      end
    end
  end
end
