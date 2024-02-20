# frozen_string_literal: true

module Levelable
  extend ActiveSupport::Concern

  included do
    enum level: {
      all_levels: 0,
      kindy: 1,
      land_one: 2,
      land_two: 3,
      land_three: 4,
      sky_one: 5,
      sky_two: 6,
      sky_three: 7,
      galaxy_one: 8,
      galaxy_two: 9,
      galaxy_three: 10,
      keep_up_one: 11,
      keep_up_two: 12,
      specialist: 13,
      specialist_advanced: 14
    }

    def primary?
      %i[all_levels kindy].exclude?(level)
    end

    def land?
      %i[land_one land_two land_three].include?(level)
    end

    def sky?
      %i[sky_one sky_two sky_three].include?(level)
    end

    def galaxy?
      %i[galaxy_one galaxy_two galaxy_three].include?(level)
    end

    def keep_up?
      %i[keep_up_one keep_up_two].include?(level)
    end

    def specialist?
      %i[specialist specialist_advanced].include?(level)
    end
  end
end
