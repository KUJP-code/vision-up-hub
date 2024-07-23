Rails.application.config.after_initialize do
  Organisation.select(:id, :name).each do |org|
    Flipper.register(:"#{org.name.downcase.tr(' ', '_')}") do |actor, context|
      actor.organisation_id == org.id
    end
  end
end
