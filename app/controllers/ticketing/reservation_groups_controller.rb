module Ticketing
  class ReservationGroupsController < BaseController
    before_action :find_group, only: [:show, :update, :destroy]

    def index
      group = authorize Ticketing::ReservationGroup.first
      redirect_to ticketing_reservation_group_path(group)
    end

    def show
      @seats = {}
      @group.reservations.each do |reservation|
        (@seats[reservation.date_id] ||= []) << reservation.seat_id
      end

      @groups = Ticketing::ReservationGroup.order(:name)
      @events = Ticketing::Event.current
      @event = params[:event_id].present? ? @events.find(params[:event_id]) : @events.first
    end

    def create
      group = authorize Ticketing::ReservationGroup.new(group_params)
      if group.save
        flash[:notice] = t("ticketing.reservation_groups.created")
        redirect_to ticketing_reservation_group_path(group.id)
      else
        redirect_to ticketing_reservation_groups_path
      end
    end

    def update
      reservations = []

      ActiveRecord::Base.transaction do
        params.require(:seats).each do |date_id, seat_ids|
          seat_ids.each do |seat_id|
            reservations << @group.reservations.where(date_id: date_id, seat_id: seat_id).first_or_create
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

      flash[:notice] = t("ticketing.reservation_groups.destroyed")
      redirect_to ticketing_reservation_groups_path
    end

    private

    def find_group
      @group = authorize Ticketing::ReservationGroup.find(params[:id])
    end

    def update_node_with_reservations(reservations)
      NodeApi.update_seats_from_records(reservations)
    rescue Errno::ENOENT # rubocop:disable Lint/HandleExceptions
    end

    def group_params
      params.require(:ticketing_reservation_group).permit(:name)
    end
  end
end
