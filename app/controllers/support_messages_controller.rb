# frozen_string_literal: true

class SupportMessagesController < ApplicationController
  def create
    @message = current_user.support_messages.new(support_message_params)
    @message.support_request_id = params[:support_request_id]

    if @message.save
      notify_participants
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

  def notify_participants
    notify_jobs = @message.support_request.participants
                          .where.not(id: @message.user_id)
                          .map do |participant|
      NotifyUserJob.new(user_id: participant.id,
                        text: t('.new_message_from', user: @message.user.name),
                        link: support_request_url(@message.support_request))
    end
    ActiveJob.perform_all_later(notify_jobs)
  end
end
