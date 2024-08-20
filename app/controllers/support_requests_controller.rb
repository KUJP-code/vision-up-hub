# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update destroy]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @support_requests = policy_scope(SupportRequest)
    @support_requests = @support_requests.includes(:user) unless current_user.is?('Parent')
  end

  def show
    @support_request.mark_seen_by(current_user.id)
    @messages = @support_request.messages.includes(:user).with_attached_images
  end

  def new
    @support_request = authorize SupportRequest.new
  end

  def edit; end

  def create
    @support_request =
      authorize current_user.support_requests.new(support_request_params)

    if @support_request.save
      notify_staff
      redirect_to @support_request,
                  notice: t('create_success')
    else
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @support_request.update(support_request_params)
      @support_request.mark_all_unseen
      redirect_to @support_request,
                  notice: t('update_success')
    else
      render :edit, status: :unprocessable_entity,
                    alert: t('update_failure')
    end
  end

  def destroy
    if @support_request.destroy
      redirect_to support_requests_url,
                  notice: t('destroy_success')
    else
      redirect_to support_requests_url,
                  alert: t('destroy_failure')
    end
  end

  private

  def support_request_params
    params.require(:support_request).permit(
      :category, :description, :internal_notes, :resolved_at, :priority,
      :resolved_by, :subject, { support_messages_attributes: %i[id body] },
      { images: [] }
    )
  end

  def notify_staff
    notify_jobs = User.where(type: %w[Admin Sales]).map do |user|
      NotifyUserJob.new(user_id: user.id,
                        text: t('.new_request_from', user: @support_request.user.name),
                        link: support_request_url(@support_request))
    end
    ActiveJob.perform_all_later(notify_jobs)
  end

  def set_support_request
    @support_request = authorize SupportRequest.find(params[:id])
  end
end
