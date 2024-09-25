# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index; end

  def show; end

  def new; end

  def edit; end

  def create; end

  def update; end

  def destroy; end
end
