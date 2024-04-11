# frozen_string_literal: true

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_area(attribute, options = {})
    super(attribute, options.reverse_merge(data: { controller: 'textarea-autogrow' }))
  end
end
