# frozen_string_literal: true

class LevelChangesController < ApplicationController
  def new
  end

  def create
    if params[:csv_file].present?
      importer = HistoricalLevelChangesImporter.new(params[:csv_file])
      importer.import

      if importer.errors.any?
        flash[:alert] = importer.errors.join(', ')
      else
        flash[:notice] = 'CSV imported successfully!'
      end
    else
      flash[:alert] = 'This doesnt work as a csv at all'
    end

    redirect_to new_level_change_path
  end
end
