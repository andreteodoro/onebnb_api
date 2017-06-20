class Reservation < ApplicationRecord
  enum status: [ :pending, :active, :finished, :paid, :canceled , :refused]

  belongs_to :property
  belongs_to :user

  has_many :talks

  before_create :set_pending_status
  validates_presence_of :property, :user


  def self.create_order reservation_params, card_params
    Reservation.transaction do
      reservation = self.create(reservation_params)
      Transaction.create(reservation: reservation, user: reservation.user, price: reservation.price, status: :pending, card: Card.create(card_params))
    end
  end

  def accept
    Reservation.transaction do
      self.update(status: :active)
      res = ::MoipApi.client.post("/v2/payments/#{self.order.moip_id}/capture", {})
      self.order.status = :success
    end
  end

  def cancel status
    Reservation.transaction do
      self.update(status: status)
      res = ::MoipApi.client.post("/v2/payments/#{self.order.moip_id}/void", {})
      self.order.status = :failed
    end
  end

  def price
    ((self.interval_of_days * self.property.price) * 1.1).to_f
  end

  def staying_days
    (self.checkout_date - self.checkin_date).to_i
  end

  def set_pending_status
    self.status ||= :pending
  end

  def evaluate comment, new_rating
    Reservation.transaction do
      property = self.property

      Comment.create(property: property, body: comment, user: self.user)

      # Calculates the new property rate
      quantity        = property.reservations.where(evaluation: true).count
      property.rating = (((property.rating * quantity) + new_rating) / (quantity + 1))
      property.save!

      self.evaluation = true
      self.save!
    end
  end
end
