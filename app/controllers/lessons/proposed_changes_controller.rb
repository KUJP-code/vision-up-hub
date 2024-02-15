# frozen_string_literal: true

class ProposedChangesController < ApplicationController
  before_action :set_change, only: %i[destroy update]
  after_action :verify_authorized

  def update
    @lesson = @change.lesson

    if @lesson.update(@change.proposals)
      @change.update(status: :accepted)
      redirect_to lesson_path(@lesson),
                  notice: 'Accepted proposed change.'
    else
      redirect_to lesson_path(@lesson),
                  alert: 'Failed to accept proposed change.'
    end
  end

  def destroy
    if @change.update(status: :rejected)
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
