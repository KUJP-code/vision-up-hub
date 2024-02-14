puts "Seeding for #{Rails.env.downcase}..."

load(Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb"))
