# frozen_string_literal: true

class CourseResource < ApplicationRecord
  belongs_to :course
  belongs_to :category_resource
end
