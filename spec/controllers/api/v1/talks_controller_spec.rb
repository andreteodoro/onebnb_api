require 'rails_helper'

RSpec.describe Api::V1::TalksController, type: :controller do
  describe 'GET #index' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'with valid params and 10 talks' do
      before do
        request.headers.merge!(@auth_headers)
        10.times do
          create(:talk, user: @user)
        end
      end

      it 'will receive 8 elements in first page' do
        get :index, page: 1
        expect(JSON.parse(response.body).count).to eql(8)
      end

      it 'will receive 2 elements in second page' do
        get :index, page: 2
        expect(JSON.parse(response.body).count).to eql(2)
      end
    end

    context 'with valid params and 4 talks where the user is client' do
      before do
        request.headers.merge!(@auth_headers)
        @talk1 = create(:talk, user: @user)
        @talk2 = create(:talk, user: @user)
        @talk3 = create(:talk, user: @user)
        @talk4 = create(:talk, user: @user)
      end

      it 'receive 4 talks' do
        get :index
        expect(JSON.parse(response.body).count).to eql(4)
      end

      it 'the results come in the right order (based in last message date)' do
        create(:message, talk: @talk3)
        create(:message, talk: @talk2)
        create(:message, talk: @talk1)
        create(:message, talk: @talk4)

        get :index

        expect(JSON.parse(response.body)[0]['talk']['id']).to eql(@talk4.id)
        expect(JSON.parse(response.body)[1]['talk']['id']).to eql(@talk1.id)
        expect(JSON.parse(response.body)[2]['talk']['id']).to eql(@talk2.id)
        expect(JSON.parse(response.body)[3]['talk']['id']).to eql(@talk3.id)
      end
    end

    context 'with valid params and 4 where the user is client in 2 and property in 2' do
      before do
        request.headers.merge!(@auth_headers)
        @talk1 = create(:talk, user: @user)
        @talk2 = create(:talk, user: @user)

        @property = create(:property, user: @user)

        @talk3 = create(:talk, property: @property)
        @talk4 = create(:talk, property: @property)
      end

      it 'receive 4 talks' do
        get :index
        expect(JSON.parse(response.body).count).to eql(4)
      end

      it 'the results come in the right order (based in last message date)' do
        create(:message, talk: @talk3)
        create(:message, talk: @talk2)
        create(:message, talk: @talk1)
        create(:message, talk: @talk4)

        get :index

        expect(JSON.parse(response.body)[0]['talk']['id']).to eql(@talk4.id)
        expect(JSON.parse(response.body)[1]['talk']['id']).to eql(@talk1.id)
        expect(JSON.parse(response.body)[2]['talk']['id']).to eql(@talk2.id)
        expect(JSON.parse(response.body)[3]['talk']['id']).to eql(@talk3.id)
      end
    end
  end
end