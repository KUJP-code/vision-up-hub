# frozen_string_literal: true

class Parent < User
  VISIBLE_TYPES = [].freeze

  has_many :children, class_name: 'Student',
                      inverse_of: :parent,
                      dependent: :nullify

  def extra_emails=(extra_emails)
    existing_emails = self.extra_emails
    new_emails = extra_emails.split(',')
                             .map(&:strip)
                             .reject { |e| existing_emails.include?(e) }
    extra_emails = existing_emails + new_emails

    super(extra_emails)
  end

  def remove_extra_email(email)
    extra_emails.delete(email)
    save
  end
end
