# frozen_string_literal: true

module Members
  class MembershipApplicationsController < ApplicationController
    skip_authorization

    before_action :prepare_new

    def new; end

    def create
      @application.assign_attributes(application_params)
      return render :new unless @application.save

      notice = t(".created_#{@application.email.present? ? 'email' : 'other'}")
      redirect_to new_members_membership_application_path, notice:
    end

    private

    def prepare_new
      @application = MembershipApplication.new
    end

    def application_params
      params.require(:members_membership_application)
            .permit(:first_name, :last_name, :gender, :birthday, :email, :phone, :street, :plz,
                    :city, :debtor_name, :iban)
    end
  end
end
