# frozen_string_literal: true

class LevelChangesController < ApplicationController
  def new; end

  def create
    file = params[:file]
    if file.blank?
      flash[:alert] = 'Please select a CSV file.'
      return redirect_to new_level_change_path
    end

    result = HistoricalLevelChangeImporter.call(file.path)

    flash[:notice] = "Import completed. #{result[:success]} records saved, #{result[:failed]} failed."
    redirect_to new_level_change_path
  end
end
