# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: %i[destroy edit update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @announcements = policy_scope(Announcement).order(start_date: :desc)
  end

  def new
    @announcement = authorize Announcement.new(organisation_id: current_user.organisation_id)
    set_form_data
  end

  def edit
    set_form_data
  end

  def create
    @announcement = authorize Announcement.new(announcement_param)
    if @announcement.save
      redirect_to announcements_url, notice: t('success')
    else
      set_form_data
      render :new, alert: t('failure')

    end
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to announcements_url, notice: t('success')
    else
      set_form_data
      render :edit, alert: t('failure')
    end
  end

  def destroy
    if @announcement.destroy
      redirect_to announcements_url, notice: t('success')
    else
      redirect_to announcements_url, alert: t('failure')
    end
  end

  private

  def announcement_params
    params.require(:announcement).permit(:message, :link, :finish_date, :start_date, :organisation_id, :role)
  end

  def set_announcement
    @announcement = authorize Announcement.find(params[:id])
  end

  def set_form_data
    @organisations = policy_scope(Organisation)
  end
end
