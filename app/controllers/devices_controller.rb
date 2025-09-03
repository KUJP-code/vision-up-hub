# frozen_string_literal: true

class DevicesController < ApplicationController
  skip_before_action :check_device_approval, only: [:pending]
  before_action :authenticate_user!
  before_action :require_admin!, only: %i[index update destroy]

  def pending
    render :pending
  end

  def index
    @pending  = Device.includes(:user).pending.order(created_at: :desc)
    @approved = Device.includes(:user).approved.order(updated_at: :desc)
    @rejected = Device.includes(:user).rejected.order(updated_at: :desc)
  end

  def update
    @device = Device.find(params[:id])
    if @device.update(device_params)
      redirect_to devices_path, notice: 'User Updated'
    else
      redirect_to devices_path, alert: 'Update Failed'
    end
  end

  def destroy
    @device = Device.find(params[:id])
    @device.destroy!
    redirect_to devices_path, notice: 'Removed device'
  end

  private

  def device_params
    params.require(:device).permit(:status)
  end

  def require_admin!
    redirect_to root_path, alert: 'Not Authorized' unless current_user.is?('Admin', 'OrgAdmin')
  end
end
