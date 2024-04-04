# frozen_string_literal: true

class ProposalsController < ApplicationController
  before_action :set_proposal, only: %i[show update]

  def show
    @lesson = @proposal.changed_lesson
  end

  def update
    return replace_lesson if proposal_params[:status] == 'accepted'

    if @proposal.update(proposal_params)
      redirect_to lesson_url(id: @proposal.changed_lesson_id),
                  notice: t('update_success')
    else
      render :show,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:changed_lesson_id, :internal_notes, :status)
  end

  def replace_lesson
    @lesson = Lesson.find(proposal_params[:changed_lesson_id])
    if @proposal.replace(@lesson)
      redirect_to lesson_url(id: @proposal.id),
                  notice: t('update_success')
    else
      render :show,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  def set_proposal
    @proposal = Lesson.find(params[:id])
  end
end
