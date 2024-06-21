# frozen_string_literal: true

class PhonicsResourcesController < ApplicationController
  after_action :verify_authorized

  def destroy
    @phonics_resource = PhonicsResource.find(params[:id])
    if @phonics_resource.destroy
      redirect_back fallback_location: lessons_path,
                    notice: 'Phonics resource deleted.'
    else
      redirect_back fallback_location: lessons_path,
                    alert: @phonics_resource.errors.full_messages
    end
  end
end
