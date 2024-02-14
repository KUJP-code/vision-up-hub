# frozen_string_literal: true

class ProposedChangesController < ApplicationController
  before_action :set_change, only: %i[destroy update]

  def update

  end

  def destroy
    @change = ProposedChange.find(params[:id])

    if @change.destroy
      redirect_to lesson_path(@change.lesson),
                  notice: 'Rejected proposed change.'
    else
      redirect_to lesson_path(@change.lesson),
                  alert: 'Failed to reject proposed change.'
    end
  end

  private

  def set_change
    @change = authorize ProposedChange.find(params[:id])
  end
end
