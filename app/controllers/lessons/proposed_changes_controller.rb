# frozen_string_literal: true

class ProposedChangesController < ApplicationController
  before_action :set_change, only: %i[destroy update]
  after_action :verify_authorized

  def update
    if @change.update(proposed_change_params)
      return accepted_change if @change.accepted?

      redirect_to lesson_path(@change.lesson),
                  notice: 'Proposed change successfully updated.'
    else
      redirect_to lesson_path(@change.lesson),
                  alert: 'Failed to update proposed change.'
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

  def proposed_change_params
    attrs = current_user.is?('Admin') ? %i[comments status] : %i[comments]
    params.require(:proposed_change).permit(attrs)
  end

  def accepted_change
    @lesson = @change.lesson

    if @lesson.update(@change.proposals)
      redirect_to lesson_path(@lesson),
                  notice: 'Applied proposed change.'
    else
      redirect_to lesson_path(@lesson),
                  alert: 'Failed to apply proposed change.'
    end
  end

  def set_change
    @change = authorize ProposedChange.find(params[:id])
  end
end
