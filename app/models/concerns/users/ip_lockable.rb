# frozen_string_literal: true

module IpLockable
  extend ActiveSupport::Concern

  included do
    def allowed_ip?(ip_address)
      school_ips = schools.pluck(:ip)

      allowed_ips = school_ips.flat_map do |school_ip|
        next [] if school_ip.blank?

        school_ip.split(',').map(&:strip)
      end
      return true if allowed_ips.include?('*')

      allowed_ips.include?(ip_address)
    end
  end
end
