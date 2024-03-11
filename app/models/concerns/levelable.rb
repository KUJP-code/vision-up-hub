# frozen_string_literal: true

module Levelable
  extend ActiveSupport::Concern
  include Levels

  included do
    enum level: LEVELS

    def primary?
      %w[all_levels kindy].exclude?(level)
    end

    def land?
      %w[land_one land_two land_three].include?(level)
    end

    def sky?
      %w[sky_one sky_two sky_three].include?(level)
    end

    def galaxy?
      %w[galaxy_one galaxy_two galaxy_three].include?(level)
    end

    def keep_up?
      %w[keep_up_one keep_up_two].include?(level)
    end

    def specialist?
      %w[specialist specialist_advanced].include?(level)
    end
  end
end
