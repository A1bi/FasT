# frozen_string_literal: true

module Ticketing
  class ReservationGroupsController < BaseController
    before_action :find_group, only: %i[show update destroy]

    def index
      authorize Ticketing::ReservationGroup
      group = Ticketing::ReservationGroup.first
      return redirect_to ticketing_reservation_group_path(group) if group.present?

      flash.now[:info] = t('.no_group_exists')
    end

    def show
      @groups = Ticketing::ReservationGroup.order(:name)
      @events = Ticketing::Event.with_future_dates.with_seating
      return flash.now[:info] = t('.no_event_exists') if @events.none?

      @event = if params[:event_id].present?
                 @events.find(params[:event_id])
               else
                 @events.first
               end

      @seats = {
        exclusive: @group.reservations,
        taken: @event.tickets.valid
      }.transform_values do |scope|
        scope.each_with_object({}) do |record, seats|
          (seats[record.date_id] ||= []) << record.seat_id
        end
      end
    end

    def create
      group = authorize Ticketing::ReservationGroup.new(group_params)
      if group.save
        redirect_to ticketing_reservation_group_path(group.id), notice: t('.created')
      else
        redirect_to ticketing_reservation_groups_path
      end
    end

    def update
      reservations = []

      ActiveRecord::Base.transaction do
        params.fetch(:seats, {}).each do |date_id, seat_ids|
          seat_ids.each do |seat_id|
            reservations << @group.reservations.where(date_id:, seat_id:).first_or_create
          end
        end

        removed = @group.reservations.where.not(id: reservations)
        reservations.concat(removed)
        removed.destroy_all
      end

      update_node_with_reservations(reservations)

      head :ok
    end

    def destroy
      reservations = @group.reservations.to_a
      @group.destroy

      update_node_with_reservations(reservations)

      redirect_to ticketing_reservation_groups_path, notice: t('.destroyed')
    end

    private

    def find_group
      @group = authorize Ticketing::ReservationGroup.find(params[:id])
    end

    def update_node_with_reservations(reservations)
      NodeApi.update_seats_from_records(reservations)
    end

    def group_params
      params.expect(ticketing_reservation_group: [:name])
    end
  end
end
