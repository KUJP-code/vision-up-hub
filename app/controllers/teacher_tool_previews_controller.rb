# frozen_string_literal: true

class TeacherToolPreviewsController < ApplicationController
  before_action :set_teacher
  after_action :verify_authorized

  def show
    @tool = TeacherTools::Resolver.call(organisation: @teacher.organisation)
                                  .find { |tool| tool.id == params[:id].to_i }

    return head :not_found unless Flipper.enabled?(:teacher_tools, @teacher)
    return head :not_found unless @tool&.kind == 'video'
  end

  private

  def set_teacher
    @teacher = authorize Teacher.find(params[:teacher_id])
  end
end
