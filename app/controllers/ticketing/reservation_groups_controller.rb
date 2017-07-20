module Ticketing
  class ReservationGroupsController < BaseController
    before_action :find_group, only: [:show, :update, :destroy]

    def index
      redirect_to ticketing_reservation_group_path(Ticketing::ReservationGroup.first)
    end

    def show
      @seats = {}
      @group.reservations.each do |reservation|
        (@seats[reservation.date_id] ||= []) << reservation.seat_id
      end

      @groups = Ticketing::ReservationGroup.order(:name)
      @dates = Ticketing::Event.current.dates
    end

    def create
      group = Ticketing::ReservationGroup.new(params.require(:ticketing_reservation_group).permit(:name))
      if group.save
        flash[:notice] = t("ticketing.reservation_groups.created")
        redirect_to ticketing_reservation_group_path(group.id)
      else
        redirect_to ticketing_reservation_groups_path
      end
    end

    def update
      reservations = []
      ids = []

      ActiveRecord::Base.transaction do
        params.require(:seats).each do |date_id, seat_ids|
          seat_ids.each do |seat_id|
            r = @group.reservations.where(date_id: date_id, seat_id: seat_id).first_or_create
            reservations << r
            ids << r.id
          end
        end

        removed = @group.reservations.where.not(id: ids)
        reservations.concat(removed)
        removed.destroy_all
      end

      NodeApi.update_seats_from_records(reservations)

      head :ok
    end

    def destroy
      reservations = @group.reservations.to_a
      @group.destroy

      NodeApi.update_seats_from_records(reservations)

      flash[:notice] = t("ticketing.reservation_groups.destroyed")
      redirect_to ticketing_reservation_groups_path
    end

    private

    def find_group
      @group = Ticketing::ReservationGroup.find(params[:id])
    end
  end
end
