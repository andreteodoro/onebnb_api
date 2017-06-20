class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :reservation
  enum status: [:failed, :success, :pending]

  before_create :set_transaction
  belongs_to :card

  def set_transaction
    order = ::MoipApi.order.create(
      own_id: 'OneBnb',
      items: [
        {
          product: reservation.property.name.to_s,
          quantity: 1,
          detail: '',
          price: price
        }
      ],
      customer: {
        own_id: "#{reservation.user.name}_#{reservation.user.id}",
        fullname: reservation.user.name,
        email: reservation.user.email
      }
    )

    ::MoipApi.payment.create(order.id,
      {
        installment_count: 1,
        delayCapture: true,
        funding_instrument: {
          method: 'CREDIT_CARD',
          credit_card: {
            expiration_month: card.expiration_month,
            expiration_year: card.expiration_year,
            number: card.number,
            cvc: card.cvc,
              holder: {
                fullname: card.holder_fullname,
                birthdate: card.holder_birthdate,
                tax_document: {
                  type: card.holder_type,
                  number: card.holder_number
                },
                phone: {
                  country_code: card.phone_country_code,
                  area_code: card.phone_area_code,
                  number: card.phone_number
                }
              }
            }
          }
      })
    self.moip_id = order.id
  end
end
