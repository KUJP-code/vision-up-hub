# frozen_string_literal: true

module Levelable
  extend ActiveSupport::Concern
  include Levels

  included do
    enum level: LEVELS

    scope :kindy, -> { where(level: %i[all_levels kindy]) }
    scope :land, -> { where(level: %i[all_levels land_one land_two land_three]) }
    scope :sky, -> { where(level: %i[all_levels sky_one sky_two sky_three]) }
    scope :galaxy, -> { where(level: %i[all_levels galaxy_one galaxy_two galaxy_three]) }
    scope :elementary, -> { land.or(sky).or(galaxy) }
    scope :keep_up, -> { where(level: %i[keep_up_one keep_up_two]) }
    scope :specialist, -> { where(level: %i[specialist specialist_advanced]) }

    def elementary?
      %w[all_levels kindy keep_up_one keep_up_two specialist specialist_advanced]
        .exclude?(level)
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

    def calendar_level
      case short_level
      when 'Land', 'Sky', 'Galaxy', 'All Levels'
        'elementary'
      else
        short_level.downcase.tr(' ', '_')
      end
    end
  end
end
