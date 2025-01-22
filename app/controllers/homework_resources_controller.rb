# frozen_string_literal: true

class HomeworkResourcesController < ApplicationController
  after_action :verify_authorized

  def destroy
    @homework_resource = HomeworkResource.find(params[:id])
    if @homework_resource.destroy
      redirect_back fallback_location: lessons_path,
                    notice: 'Homework resource deleted.'
    else
      redirect_back fallback_location: lessons_path,
                    alert: @homework_resource.errors.full_messages
    end
  end
end
