# frozen_string_literal: true

class DevicesController < ApplicationController
  skip_before_action :check_device_approval, only: [:pending]

  def pending
    render :pending
  end
end
