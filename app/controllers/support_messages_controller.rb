# frozen_string_literal: true

class SupportMessagesController < ApplicationController
  def create
    @message = current_user.support_messages.new(support_message_params)
    @message.support_request_id = params[:support_request_id]

    if @message.save
      redirect_to support_request_path(@message.support_request),
                  notice: t('create_success')
    else
      redirect_to support_request_path(@message.support_request),
                  alert: t('create_failure')
    end
  end

  private

  def support_message_params
    params.require(:support_message).permit(:message, images: [])
  end
end
