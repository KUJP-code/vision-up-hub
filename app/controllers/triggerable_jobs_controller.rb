# frozen_string_literal: true

class TriggerableJobsController < ApplicationController
  def index
    @types = Lesson::TYPES.map { |type| [type.titleize, type] }
  end

  def create
    type = params[:type]
    return unless Lesson::TYPES.include?(type)

    type.constantize.find_each do |lesson|
      p "queuing lesson #{lesson.id}"
      RegenerateGuidesJob.perform_later(lesson)
      p SolidQueue::Job.count
    end
  end
end
