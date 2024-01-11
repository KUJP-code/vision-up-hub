# frozen_string_literal: true

class User < ApplicationRecord
  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
