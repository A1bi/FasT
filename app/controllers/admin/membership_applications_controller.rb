# frozen_string_literal: true

module Admin
  class MembershipApplicationsController < ApplicationController
    before_action :find_application, only: %i[show destroy]

    def index
      applications = authorize Members::MembershipApplication.all
      @open_applications = applications.open
      @completed_applications = applications.completed
    end

    def show; end

    def destroy
      flash.notice = t('.destroyed') if @application.destroy
      redirect_to admin_members_membership_applications_path
    end

    private

    def find_application
      @application = authorize Members::MembershipApplication.find(params[:id])
    end
  end
end
