# frozen_string_literal: true

module Levelable
  extend ActiveSupport::Concern
  include Levels

  included do
    enum level: LEVELS

    scope :primary, -> { where.not(level: %i[all_levels kindy]) }
    scope :land, -> { where(level: %i[land_one land_two land_three]) }
    scope :sky, -> { where(level: %i[sky_one sky_two sky_three]) }
    scope :galaxy, -> { where(level: %i[galaxy_one galaxy_two galaxy_three]) }
    scope :keep_up, -> { where(level: %i[keep_up_one keep_up_two]) }
    scope :specialist, -> { where(level: %i[specialist specialist_advanced]) }

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

    def short_level
      case level
      when 'land_one', 'land_two', 'land_three'
        'Land'
      when 'sky_one', 'sky_two', 'sky_three'
        'Sky'
      when 'galaxy_one', 'galaxy_two', 'galaxy_three'
        'Galaxy'
      when 'keep_up_one', 'keep_up_two'
        'Keep Up'
      when 'specialist', 'specialist_advanced'
        'Specialist'
      else
        level.titleize
      end
    end
  end
end
