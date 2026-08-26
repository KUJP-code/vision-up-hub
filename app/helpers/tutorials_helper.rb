# frozen_string_literal: true

module TutorialsHelper
  REORDER_ACTIONS = [
    'dragstart->auto-reorder#dragStart',
    'dragover->auto-reorder#dragOver',
    'drop->auto-reorder#drop',
    'dragend->auto-reorder#dragEnd'
  ].join(' ').freeze

  def tutorial_reorder_data(url, param)
    return {} unless current_user.is?('Admin', 'Sales')

    {
      controller: 'auto-reorder',
      'auto-reorder-url-value': url,
      'auto-reorder-param-value': param
    }
  end

  def tutorial_reorder_item_data(id)
    return {} unless current_user.is?('Admin', 'Sales')

    {
      'auto-reorder-target': 'item',
      reorder_id: id,
      action: REORDER_ACTIONS
    }
  end

  def tutorial_draggable?
    current_user.is?('Admin', 'Sales')
  end
end
