json.array! @talks do |talk|
    json.extract! talk, :id, :created_at , :updated_at

    # Show the last message date
    json.date talk.messages.first.created_at if talk.messages.count >= 1

    # Show the last message if present
    json.message talk.messages.first if talk.messages.present?

    json.user do
      # Show the information about the other user at the talk
      @user = (current_api_v1_user == talk.property.user) ? talk.user : talk.property.user
      json.extract! @user, :id, :name, :photo
    end

    if talk.reservation
      json.reservation do
        json.extract! talk.reservation, :id, :status
        json.interval talk.reservation.staying_days
        # TODO: Mudar no futuro para que use o preço que for gerado quando o reserva for aceita
        json.price (talk.reservation.staying_days * talk.property.price)
      end
    end
end
