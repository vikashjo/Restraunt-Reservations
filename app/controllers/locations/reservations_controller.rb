module Locations
  class ReservationsController < ApplicationController
    before_action :set_location

    def new
      @reservation = @location.reservations.new
    end

    def create
      @reservation = @location.reservations.new(reservation_date: params[:reservation_date])
      @reservation.customer = current_customer
      if @location.within_operating_hours(@reservation.reservation_date)
        before_date = @reservation.reservation_date - 15.minutes
        after_date = @reservation.reservation_date + 15.minutes
        if @location.reservations.where(reservation_date: before_date..after_date).count >= @location.table_limit
          redirect_to new_location_reservation_path(@location), alert: "Selected time is already booked, Please choose a new time"
        else
          @reservation.save!
          redirect_to booking_path, notice: "Your reservation is successfully booked"
        end
      else
        redirect_to new_location_reservation_path(@location), alert: "Your reservation time is outside of the reservation hours"
      end 
    end

    private

    def set_location
      @location = Location.find(params[:location_id])
    end


  end
end