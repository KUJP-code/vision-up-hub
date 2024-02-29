# frozen_string_literal: true

class SupportRequestsController < ApplicationController
  before_action :set_support_request, only: %i[show edit update destroy]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @support_requests = policy_scope(SupportRequest)
  end

  def show
    # @support_messages = policy_scope(@support_request.support_messages)
  end

  def new
    @support_request = authorize SupportRequest.new
  end

  def edit; end

  def create
    @support_request = authorize SupportRequest.new(
      support_request_params.merge(user_id: current_user.id)
    )

    if @support_request.save
      redirect_to @support_request,
                  notice: t('create_success')
    else
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @support_request.update(support_request_params)
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
      :category, :description, :internal_notes, :resolved_at,
      :resolved_by, :subject, support_messages_attributes: %i[id body]
    )
  end

  def set_support_request
    @support_request = authorize SupportRequest.find(params[:id])
  end
end
