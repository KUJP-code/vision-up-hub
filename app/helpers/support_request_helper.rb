# frozen_string_literal: true

module SupportRequestHelper
  def prio_color
    { 'low' => 'bg-success',
      'medium' => 'bg-warn',
      'high' => 'bg-danger' }
  end

  def prio_radio_class
    base = 'h-fit flex items-center justify-center cursor-pointer ' \
           'place-self-center relative py-2.5 basis-1/3 rounded ' \
           'btn-outline font-bold has-[:checked]:text-white'

    { 'low' => "#{base} has-[:checked]:bg-success has-[:checked]:border-success",
      'medium' => "#{base} has-[:checked]:bg-warn has-[:checked]:border-warn",
      'high' => "#{base} has-[:checked]:bg-danger has-[:checked]:border-danger" }
  end
end
