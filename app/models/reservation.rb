class Reservation < ApplicationRecord
  enum status: [ :pending, :active, :finished, :paid, :canceled , :refused]

  belongs_to :property
  belongs_to :user

  has_many :talks

  before_create :set_pending_status
  validates_presence_of :property, :user

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
