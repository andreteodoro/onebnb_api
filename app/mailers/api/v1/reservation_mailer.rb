class Api::V1::ReservationMailer < ApplicationMailer
  default from: 'noreply@onebnb.com'

  def new_reservation(reservation)
    @reservation = reservation
    mail(to: @reservation.property.user.email, subject: 'Você tem um novo pedido de reserva \o/')
  end
end