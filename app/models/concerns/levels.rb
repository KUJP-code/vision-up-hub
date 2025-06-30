# frozen_string_literal: true

module Levels
  LEVELS = {
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
  }.freeze

  LEVEL_ORDER_MAP = {
    'land_one' => 1,
    'land_two' => 2,
    'land_three' => 2,
    'sky_one' => 3,
    'sky_two' => 4,
    'sky_three' => 4,
    'galaxy_one' => 5,
    'galaxy_two' => 6,
    'galaxy_three' => 6,
    'keep_up_one' => 7,
    'keep_up_two' => 7,
    'specialist' => 8,
    'specialist_advanced' => 8
  }.freeze

  LEVEL_DATE_MAP = {
    'land_one' => :land_1_date,
    'land_two' => :land_2_date,
    'land_three' => :land_2_date,
    'sky_one' => :sky_1_date,
    'sky_two' => :sky_2_date,
    'sky_three' => :sky_2_date,
    'galaxy_one' => :galaxy_1_date,
    'galaxy_two' => :galaxy_2_date,
    'galaxy_three' => :galaxy_2_date,
    'keep_up_one' => nil,
    'keep_up_two' => nil,
    'specialist' => nil,
    'specialist_advanced' => nil
  }.freeze

  EVENING_COURSES = %w[keep_up_one keep_up_two keep_up_three
                       specialist specialist_advanced].freeze

  KEEP_UP_COURSES = %w[keep_up_one keep_up_two keep_up_three].freeze
end
