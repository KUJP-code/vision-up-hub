# frozen_string_literal: true

class NotificationsController < ApplicationController
  after_action :verify_authorized, except: :index

  def index
    return unless current_user.is?('Admin')

    @recent_notifications = SolidQueue::Job
                            .where(queue_name: 'materials_production_notifications')
                            .order(updated_at: :desc).limit(10)
    notified_ids = @recent_notifications.map { |n| n.arguments['arguments'].first['user_id'] }
    @notified_users = User.where(id: notified_ids)
  end

  def show
    @notification = authorize current_user.notifications[params[:id].to_i]
    current_user.mark_notification_read(index: params[:id])
    Rails.logger.info "REDIRECTING TO: #{@notification.link.inspect}"
    redirect_to @notification.link
  end

  def new
    @notification = authorize Notification.new
    @organisations = policy_scope(Organisation).pluck(:name, :id)
  end

  def create
    @organisation = validate_organisation
    @user_type = validate_user_type
    @notification = authorize Notification.new(notification_params.except(:organisation_id, :user_type))

    notify_jobs = user_query(@organisation, @user_type)
                  .map do |user_id|
      NotifyUserJob.new(user_id:, text: @notification.text,
                        link: @notification.link)
    end
    ActiveJob.perform_all_later(notify_jobs)

    redirect_to notifications_url,
                notice: create_notice(@notification, @organisation, @user_type)
  end

  def update
    @user = authorize current_user
    @user.mark_notification_read(index: params[:id])
    @notifications = @user.notifications
  end

  def destroy
    authorize :notification
    @user = current_user
    @user.delete_notification(index: params[:id])
  end

  private

  def notification_params
    params.require(:notification).permit(:link, :text)
  end

  def create_notice(notification, org, user_type)
    org_string = org ? ", at #{org.name}" : ''
    user_type_string = user_type ? ", for #{user_type.titleize.pluralize}" : ''

    "Queued notifications with text: #{notification.text}#{user_type_string}#{org_string}"
  end

  def user_query(org, user_type)
    scope = policy_scope(User)
    scope = scope.where(organisation: org) if org
    scope = scope.where(type: user_type) if user_type

    scope.ids
  end

  def validate_organisation
    return nil if params[:organisation_id].blank?

    authorize Organisation.find(params[:organisation_id])
  end

  def validate_user_type
    return nil if params[:user_type].blank?
    return params[:user_type] if User::TYPES.include? params[:user_type]

    @notification.errors.add(:user_type, 'is not valid')
    nil
  end
end
