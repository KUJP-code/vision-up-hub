# frozen_string_literal: true

class Parent < User
  before_validation :check_extra_emails

  CSV_HEADERS = %w[name email password].freeze
  VISIBLE_TYPES = [].freeze

  has_many :form_submissions, dependent: :restrict_with_error,
                              inverse_of: :parent
  has_many :children, class_name: 'Student',
                      inverse_of: :parent,
                      dependent: :nullify

  def extra_emails=(extra_emails)
    existing_emails = self.extra_emails
    new_emails =
      extra_emails.split(',')
                  .map(&:strip)
                  .reject { |e| existing_emails.include?(e) }
    extra_emails = existing_emails + new_emails

    super
  end

  def remove_extra_email(email)
    extra_emails.delete(email)
    save
  end

  private

  def check_extra_emails
    return true if extra_emails.all? { |e| e.match?(URI::MailTo::EMAIL_REGEXP) }

    errors.add(:extra_emails, 'invalid email')
    false
  end
end
