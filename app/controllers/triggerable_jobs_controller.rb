# frozen_string_literal: true

class TriggerableJobsController < ApplicationController
  def index
    @types = Lesson::TYPES.map { |type| [type.titleize, type] }
  end

  def create
    type = params[:type]
    return unless Lesson::TYPES.include?(type)

    type.constantize.find_each do |lesson|
      RegenerateGuidesJob.perform_later(lesson)
    end

    redirect_to triggerable_jobs_path,
                notice: "Queued updates for all #{type.titleize} lessons"
  end
end
