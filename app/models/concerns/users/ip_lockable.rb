# frozen_string_literal: true

module IpLockable
  extend ActiveSupport::Concern

  included do
    def allowed_ip?(ip)
      ips = schools.pluck(:ip)
      ips.include?('*') || ips.include?(ip)
    end
  end
end
