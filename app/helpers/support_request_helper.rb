# frozen_string_literal: true

module SupportRequestHelper
  def prio_colors
    {
      'low' => 'bg-success',
      'medium' => 'bg-warn',
      'high' => 'bg-danger'
    }
  end
end
