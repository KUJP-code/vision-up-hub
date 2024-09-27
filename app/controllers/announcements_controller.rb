# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @announcements = policy_scope(Announcement)
  end

  def show; end

  def new
    @announcement = authorize Announcement.new(organisation_id: current_user.organisation_id)
    set_form_data
  end

  def edit; end

  def create
    @announcement = authorize Announcement.new(announcement_params)
    if @announcement.save
      redirect_to announcements_url, notice: t('success')
    else
      set_form_data
      render :new, alert: t('failure')

    end
  end

  def update; end

  def destroy; end

  private

  def announcement_params
    params.require(:announcement).permit(:message, :link, :finish_date, :start_date, :organisation_id, :role)
  end

  def set_form_data
    @organisations = policy_scope(Organisation)
  end
end
