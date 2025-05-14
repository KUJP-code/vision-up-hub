unless ENV['SECRET_KEY_BASE_DUMMY']
  Rails.application.config.after_initialize do
    if ActiveRecord::Base.connection.data_source_exists?("organisations")
      Organisation.select(:id, :name).each do |org|
        Flipper.register(:"#{org.name.downcase.tr(' ', '_')}") do |actor, _context|
          actor.organisation_id == org.id
        end
      end
    end
  end
end
