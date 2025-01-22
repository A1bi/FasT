# frozen_string_literal: true

module Admin
  class MembershipFeeDebitSubmissionsController < ApplicationController
    def index
      @submissions = authorize Members::MembershipFeeDebitSubmission.order(created_at: :desc)
    end

    def show
      @submission = authorize Members::MembershipFeeDebitSubmission.find(params[:id])
    end
  end
end
