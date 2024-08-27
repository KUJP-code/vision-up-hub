Rails.application.config.after_initialize do
  ActiveModel::Type.register(:option_collection, OptionCollectionType)
end
