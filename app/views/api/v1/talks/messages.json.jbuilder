json.talk do
  json.user do
    # Show the information about the other user at the talk
    @user = (current_api_v1_user == @talk.property.user) ? @talk.user : @talk.property.user
    json.extract! @user, :id, :name, :photo, :phone, :email
  end

  if @talk.reservation
    json.reservation do
      json.extract! @talk.reservation, :id, :status, :checkin_date, :checkout_date
      json.staying_days @talk.reservation.staying_days
      # TODO: Mudar no futuro para que use o preço que for gerado quando o reserva for aceita
      json.price (@talk.reservation.staying_days * @talk.reservation.property.price)

      json.address do
        json.extract @talk.reservation.property.address, :country,
                                                         :state,
                                                         :city,
                                                         :neighborhood,
                                                         :street,
                                                         :number,
                                                         :zipcode,
                                                         :latitude,
                                                         :longitude
      end
    end
  end

  json.messages do
    json.array! @talk.messages.order("created_at DESC") do |message|
      json.extract! message, :id, :body, :created_at

      json.user do
        json.extract! message.user, :id, :name, :photo
      end
      # Tells if is the own user
      json.message_owner (current_api_v1_user == message.user)
    end
  end
end
