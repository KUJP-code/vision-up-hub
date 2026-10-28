# frozen_string_literal: true

# Temporary event accounts have access only to the AI Sensei demo.
class AiSensei < User
  VISIBLE_TYPES = [].freeze
end
