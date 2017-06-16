class ReservationJob < ApplicationJob
  queue_as :important

  def perform reservation
    if reservation.status == 'active'
      reservation.update(status: :canceled)
    end
  end
end
