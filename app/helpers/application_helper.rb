# frozen_string_literal: true

module ApplicationHelper
  def ja_date(date)
    date.strftime('%Y年%m月%d日')
  end

  def ja_datetime(datetime)
    datetime.strftime('%Y年%m月%d日 %H:%M')
  end

  def split_on_capitals(string)
    string.gsub(/.(?=[[:upper:]])/) { |c| "#{c} " }
  end
end
