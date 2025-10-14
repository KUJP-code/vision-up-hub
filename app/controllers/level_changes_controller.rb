# frozen_string_literal: true

class LevelChangesController < ApplicationController
  def new; end

  def create
    if params[:csv_file].present?
      importer = HistoricalLevelChangesImporter.new(params[:csv_file])
      importer.import

      if importer.errors.any?
        max_display_errors = 3
        displayed_errors = importer.errors.first(max_display_errors)
        remaining_count = importer.errors.size - displayed_errors.size

        flash[:alert] = if remaining_count.positive?
                          "#{displayed_errors.join(', ')} (and #{remaining_count} more errors)"
                        else
                          displayed_errors.join(', ')
                        end
      else
        flash[:notice] = 'CSV imported successfully!'
      end

    else
      flash[:alert] = 'This doesnt work as a csv at all'
    end

    redirect_to new_level_change_path
  end
end
