module LevelBucket
  BUCKET_MAP = {
    'land_one' => 'land', 'land_two' => 'land', 'land_three' => 'land',
    'sky_one' => 'sky', 'sky_two' => 'sky', 'sky_three' => 'sky',
    'galaxy_one' => 'galaxy', 'galaxy_two' => 'galaxy', 'galaxy_three' => 'galaxy',
    'kindy' => 'kindy'
  }.freeze

  def self.for(level)
    BUCKET_MAP[level.to_s]
  end
end