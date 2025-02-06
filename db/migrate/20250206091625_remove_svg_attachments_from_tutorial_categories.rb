class RemoveSvgAttachmentsFromTutorialCategories < ActiveRecord::Migration[6.1]
  def up
    ActiveStorage::Attachment.where(record_type: 'TutorialCategory', name: 'svg').find_each do |attachment|
      attachment.purge
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
