# frozen_string_literal: true

module Topicable
  extend ActiveSupport::Concern

  included do
    before_validation :set_topic

    attr_accessor :lesson_topic, :term, :unit

    with_options if: proc { |l| l.topic.nil? } do
      validates :lesson_topic, presence: true
      validates :term, inclusion: { in: (1..3).map(&:to_s) }
      validates :unit, inclusion: { in: (1..20).map(&:to_s) }
    end

    def lesson_topic
      return @lesson_topic if topic.blank?
      return @lesson_topic if @lesson_topic.present?

      topic[/- (.+)$/, 1]
    end

    def term
      return @term if topic.blank?
      return @term if @term.present?

      topic[/Term (\d+)/, 1]
    end

    def unit
      return @unit if topic.blank?
      return @unit if @unit.present?

      topic[/Unit (\d+)/, 1]
    end
  end

  def set_topic
    return if lesson_topic.blank? || term.blank? || unit.blank?

    self.topic = "Term #{term} Unit #{unit} - #{lesson_topic}"
  end
end
