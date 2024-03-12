# frozen_string_literal: true

module StudentHelper
  def redact(name)
    current_user.ku? ? '****' : name
  end
end
