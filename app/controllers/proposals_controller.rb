# frozen_string_literal: true

class ProposalsController < ApplicationController
  before_action :set_proposal, only: %i[show update]

  def show
    @lesson = @proposal.changed_lesson
  end

  def update; end

  private

  def set_proposal
    @proposal = Lesson.find(params[:id])
  end
end
