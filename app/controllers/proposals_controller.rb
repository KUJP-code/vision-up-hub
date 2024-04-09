# frozen_string_literal: true

class ProposalsController < ApplicationController
  before_action :set_proposal, only: %i[show update]
  after_action :verify_authorized

  def show
    @lesson = authorize @proposal.changed_lesson
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
    params.require(:proposal).permit(:internal_notes, :status)
  end

  def replace_lesson
    @lesson = authorize @proposal.changed_lesson
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
    @proposal = authorize(Lesson.find(params[:id]), policy_class: ProposalPolicy)
  end
end
