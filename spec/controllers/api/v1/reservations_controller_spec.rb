require 'rails_helper'

RSpec.describe Api::V1::ReservationsController, type: :controller do
  describe 'GET #evaluation' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'with 4 existing reservations and rating 5' do
      before do
        request.headers.merge!(@auth_headers)

        @property1 = create(:property, status: :active, rating: 5)
        @reservation1 = create(:reservation, property: @property1, evaluation: true, user: @user)
        @reservation2 = create(:reservation, property: @property1, evaluation: true, user: @user)
        @reservation3 = create(:reservation, property: @property1, evaluation: true, user: @user)
        @reservation4 = create(:reservation, property: @property1, evaluation: true, user: @user)
      end

      it 'return rating 4 when new rating is 0' do
        @reservation5 = create(:reservation, property: @property1, evaluation: false, user: @user)

        post :evaluation, params: { id: @reservation5.id, evaluation: { comment: FFaker::Lorem.paragraph, rating: 0 } }
        @property1.reload
        expect(@property1.rating).to eql(4)
      end

      it 'return rating 5 when new rating is 5' do
        @reservation5 = create(:reservation, property: @property1, evaluation: false, user: @user)

        post :evaluation, params: { id: @reservation5.id, evaluation: { comment: FFaker::Lorem.paragraph, rating: 5 } }
        @property1.reload
        expect(@property1.rating).to eql(5)
      end

      it 'return comment' do
        @reservation5 = create(:reservation, property: @property1, evaluation: false, user: @user)
        comment = FFaker::Lorem.paragraph
        post :evaluation, params: { id: @reservation5.id, evaluation: { comment: comment, rating: 5 } }
        @property1.reload
        expect(Comment.last.body).to eql(comment)
      end
    end
  end

  describe 'POST #create' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'with valid params' do
      before do
        request.headers.merge!(@auth_headers)
        @property1 = create(:property, status: :active, rating: 5)
      end

      it 'will send a notification mail to Property Owner' do
        post :create, params: { reservation: { property_id: @property1.id, checkin_date: Date.today - 10.day, checkout_date: Date.today + 10.day } }
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq([Reservation.last.property.user.email])
      end

      it 'create a valid reservation' do
        post :create, params: { reservation: { property_id: @property1.id, checkin_date: Date.today - 10.day, checkout_date: Date.today + 10.day } }
        expect(Reservation.all.count).to eql(1)
      end

      it 'create a reservation with correspondents fields' do
        new_reservation_params = { reservation: { property_id: @property1.id, checkin_date: Date.today - 10.day, checkout_date: Date.today + 10.day } }

        post :create, params: new_reservation_params

        @reservation = Reservation.last

        expect(@reservation.property_id).to eql(new_reservation_params[:reservation][:property_id])
        expect(@reservation.checkin_date).to eql(new_reservation_params[:reservation][:checkin_date])
        expect(@reservation.checkout_date).to eql(new_reservation_params[:reservation][:checkout_date])
        expect(@reservation.user).to eql(@user)
      end

      it 'create a reservation with valid fields and correct JSON is returned' do
        new_reservation_params = { reservation: { property_id: @property1.id, checkin_date: Date.today - 10.day, checkout_date: Date.today + 10.day } }

        post :create, params: new_reservation_params

        @reservation = Reservation.last

        expect(JSON.parse(response.body)['id']).to eql(@reservation.id)
        expect(JSON.parse(response.body)['status']).to eql(@reservation.status)
        expect(JSON.parse(response.body)['checkin_date']).to eql(@reservation.checkin_date.strftime('%Y-%m-%d'))
        expect(JSON.parse(response.body)['checkout_date']).to eql(@reservation.checkout_date.strftime('%Y-%m-%d'))
        expect(JSON.parse(response.body)['evaluation']).to eql(@reservation.evaluation)
        expect(JSON.parse(response.body)['status']).to eql(@reservation.status)
        expect(JSON.parse(response.body)['user']['id']).to eql(@reservation.user.id)
      end
    end
  end

  describe 'GET #get_by_property' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'with valid params and 4 reservations' do
      before do
        request.headers.merge!(@auth_headers)
        @property1 = create(:property, status: :active, rating: 5, user: @user)
        @reservation1 = create(:reservation, property: @property1, evaluation: true)
        @reservation2 = create(:reservation, property: @property1, evaluation: true)
        @reservation3 = create(:reservation, property: @property1, evaluation: true)
        @reservation4 = create(:reservation, property: @property1, evaluation: true)
      end

      it 'receive 4 reservations' do
        get :get_by_property, params: { id: @property1.id }
        expect(JSON.parse(response.body).count).to eql(4)
      end
    end
  end

  describe 'POST #cancel' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'User is owner of the Reservation' do
      before do
        request.headers.merge!(@auth_headers)
        @reservation = create(:reservation, user: @user, status: :pending)
      end

      it 'will send a notification mail to Property Owner' do
        post :cancel, params: { id: @reservation.id }
        expect(ActionMailer::Base.deliveries.last.to).to eq([Reservation.last.property.user.email])
      end

      it 'Change status of pending to canceled' do
        post :cancel, params: { id: @reservation.id }
        @reservation.reload
        expect(@reservation.status).to eql('canceled')
      end

      it 'Receive status 200' do
        post :cancel, params: { id: @reservation.id }
        expect(response.status).to eql(200)
      end
    end

    context 'User is not the owner of the Reservation' do
      before do
        request.headers.merge!(@auth_headers)
        @reservation = create(:reservation, status: :pending)
      end

      it 'Status keep pending' do
        post :cancel, params: { id: @reservation.id }
        @reservation.reload
        expect(@reservation.status).to eql('pending')
      end

      it 'Receive status 403' do
        post :cancel, params: { id: @reservation.id }
        expect(response.status).to eql(403)
      end
    end
  end

  describe 'POST #accept' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
      ActionMailer::Base.deliveries = []
    end

    context 'User is property owner' do
      before do
        request.headers.merge!(@auth_headers)
        @property = create(:property, user: @user)
        @reservation = create(:reservation, status: :pending, property: @property)
      end

      it 'Change status of pending to active' do
        put :accept, params: { id: @reservation.id }
        @reservation.reload
        expect(@reservation.status).to eql('active')
      end

      it 'Receive status 200' do
        put :accept, params: { id: @reservation.id }
        expect(response.status).to eql(200)
      end

      it 'will send a notification mail to Reservation User' do
        put :accept, params: { id: @reservation.id }
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq([Reservation.last.user.email])
      end
    end

    context 'User is not the owner of the Property' do
      before do
        request.headers.merge!(@auth_headers)
        @reservation = create(:reservation, status: :pending)
      end

      it 'Status keep pending' do
        put :accept, params: { id: @reservation.id }
        @reservation.reload
        expect(@reservation.status).to eql('pending')
      end

      it 'Receive status 403' do
        put :accept, params: { id: @reservation.id }
        expect(response.status).to eql(403)
      end
    end
  end

  describe 'PUT #refuse' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
      ActionMailer::Base.deliveries = []
    end

    context 'User is property owner' do
      before do
        request.headers.merge!(@auth_headers)
        @property = create(:property, user: @user)
        @reservation = create(:reservation, status: :pending, property: @property)
      end

      it 'Change status of pending to refused' do
        put :refuse, params: { id: @reservation.id }
        @reservation.reload
        expect(@reservation.status).to eql('refused')
      end

      it 'Receive status 200' do
        put :refuse, params: { id: @reservation.id }
        expect(response.status).to eql(200)
      end

      it 'will send a notification mail to Reservation User' do
        put :refuse, params: { id: @reservation.id }
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq([Reservation.last.user.email])
      end
    end

    context 'User is not the owner of the Property' do
      before do
        request.headers.merge!(@auth_headers)
        @reservation = create(:reservation, status: :pending)
      end

      it 'Status keep pending' do
        post :refuse, params: { id: @reservation.id }
        @reservation.reload
        expect(@reservation.status).to eql('pending')
      end

      it 'Receive status 403' do
        post :refuse, params: { id: @reservation.id }
        expect(response.status).to eql(403)
      end
    end
  end
end
