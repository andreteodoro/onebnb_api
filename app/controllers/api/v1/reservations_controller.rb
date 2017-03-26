class Api::V1::ReservationsController < ApplicationController
  before_action :set_api_v1_reservation, only: [:evaluation, :cancel]
  before_action :authenticate_api_v1_user!

  # POST /api/v1/reservation.json
  def create
    @api_v1_reservation = Reservation.new(reservation_params)
    if @api_v1_reservation.save
      ReservationMailer.new_reservation(@api_v1_reservation).deliver_now
      render :show, status: :created
    else
      render json: @api_v1_reservation.errors, status: :unprocessable_entity
    end
  end

  # POST /evaluation # POST /evaluation.json
  def evaluation
    @api_v1_reservation.evaluate(evaluation_params[:comment], evaluation_params[:rating].to_i) unless @api_v1_reservation.evaluation
    render json: { success: true }, status: 200
  rescue Exception => errors
    render json: errors, status: :unprocessable_entity
  end

  # GET /get_by_property
  # GET /get_by_property.json
  def get_by_property
    @api_v1_reservation = current_api_v1_user.properties.find(params[:id]).reservations
    render template: '/api/v1/reservations/index', status: 200
  rescue Exception => errors
    render json: errors, status: :unprocessable_entity
  end

  # POST /cancel
  # POST /cancel.json
  def cancel
    @api_v1_reservation.update(status: :canceled)
    Api::V1::ReservationMailer.cancel_reservation(@api_v1_reservation).deliver_now
    render json: { success: true }, status: 200
  rescue Exception => errors
    render json: errors, status: :unprocessable_entity
  end

  private

  def set_api_v1_reservation
    @api_v1_reservation = Reservation.where(id: params[:id], user: current_api_v1_user).last
  end

  def evaluation_params
    params.require(:evaluation).permit(:comment, :rating)
  end

  def reservation_params
    params.require(:reservation).permit(:property_id, :checkin_date, :checkout_date).merge(user_id: current_api_v1_user.id)
  end
end
