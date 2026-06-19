# frozen_string_literal: true

module Proposable
  extend ActiveSupport::Concern
  NOT_PROPOSABLE =
    %w[admin_approval assigned_editor_id changed_lesson_id created_at
       creator_id curriculum_approval id released resource_deletions status type
       updated_at].freeze

  included do
    belongs_to :changed_lesson,
               class_name: 'Lesson',
               optional: true

    has_many :proposals, class_name: 'Lesson',
                         foreign_key: :changed_lesson_id,
                         inverse_of: :changed_lesson,
                         dependent: :nullify
    enum status: {
      proposed: 0,
      changes_needed: 1,
      rejected: 2,
      accepted: 3
    }

    def replace_with(proposal)
      self.class.transaction do
        assign_proposable_attributes(proposal)
        replace_lesson_content(proposal)
        save!
        proposal.update!(status: :accepted)
      end
    rescue StandardError => e
      Rails.logger.error(e.message)
      false
    end
  end

  private

  def assign_proposable_attributes(proposal)
    proposal.attributes.each do |key, value|
      next if NOT_PROPOSABLE.include?(key)

      send(:"#{key}=", value)
    end
  end

  def replace_lesson_content(proposal)
    replace_single_attachments(proposal)
    replace_lesson_links(proposal)
    replace_resources(proposal)
    replace_phonics_resources(proposal) if type == 'PhonicsClass'
    replace_specialist_resources(proposal) if type == 'EveningClass'
  end

  def replace_single_attachments(proposal)
    proposal.attachment_reflections.each do |name, reflection|
      next unless reflection.macro == :has_one_attached

      attachment = proposal.public_send(name)
      next unless attachment.attached?

      public_send(name).attach(attachment.blob)
    end
  end

  def replace_lesson_links(proposal)
    lesson_links.destroy_all

    proposal.lesson_links.each do |link|
      lesson_links.build(title: link.title, url: link.url)
    end
  end

  def replace_resources(proposal)
    replace_attached_resources_from_proposal(proposal, :resources)
  end

  def replace_attached_resources_from_proposal(proposal, attachment_name)
    purge_proposed_resource_deletions(proposal, attachment_name)
    attach_proposed_resources(proposal, attachment_name)
  end

  def purge_proposed_resource_deletions(proposal, attachment_name)
    blob_ids = proposal.resource_deletion_blob_ids(attachment_name)
    public_send(:"#{attachment_name}_attachments").where(blob_id: blob_ids).find_each(&:purge)
  end

  def attach_proposed_resources(proposal, attachment_name)
    proposal.public_send(attachment_name).each do |resource|
      blob = resource.respond_to?(:blob) ? resource.blob : resource
      next if proposal.resource_deleted?(attachment_name, blob.id)
      next if resource_attached?(attachment_name, blob)

      public_send(attachment_name).attach(blob)
    end
  end

  def resource_attached?(attachment_name, blob)
    public_send(attachment_name).any? { |existing| existing.filename == blob.filename }
  end

  def replace_phonics_resources(proposal)
    proposal.phonics_resources.each do |resource|
      next if phonics_resource_duplicated?(resource)

      phonics_resources.create!(blob_id: resource.blob_id, week: resource.week)
    end
  end

  def phonics_resource_duplicated?(resource)
    phonics_resources.find_by(blob_id: resource.blob_id, week: resource.week)
  end

  def replace_specialist_resources(proposal)
    return unless respond_to?(:specialist_structured?) && specialist_structured?

    self.class.specialist_resource_attachment_names.each do |attachment_name|
      public_send(attachment_name).purge
      proposal.public_send(attachment_name).each do |resource|
        next if proposal.resource_deleted?(attachment_name, resource.blob_id)

        public_send(attachment_name).attach(resource.blob)
      end
    end
  end
end
