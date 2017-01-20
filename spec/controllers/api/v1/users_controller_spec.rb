require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'PUT #update' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      @new_attributes = { name: FFaker::Name.name }
      # Setting the request as json (the URL users.json will be use instead of users)
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'with valid params and tokens' do
      before do
        # Merge the token into the Header
        request.headers.merge!(@auth_headers)
      end

      it 'updates the requested user' do
        put :update, params: { id: @user.id, user: @new_attributes }
        @user.reload
        expect(@user.name).to eql(@new_attributes[:name])
      end

      it 'updates the password' do
        @current_password = @user.password
        @new_password = { password: FFaker::Internet.password }
        put :update, params: { id: @user.id, user: @new_password }
        @user.reload
        expect(@user.password).to eql(@current_password)
      end

      it 'updates the email' do
        @new_email = { email: FFaker::Internet.email }
        put :update, params: { id: @user.id, user: @new_email }
        @user.reload
        expect(@user.email).to eql(@new_email[:email])
      end

      it 'updates the requested user with photo' do
        @attributes_with_photo = @new_attributes.merge!(
          photo: ('data:image/png;base64,' + Base64.encode64(file_fixture('file.png').read))
        )
        put :update, params: { id: @user.id, user: @attributes_with_photo }
        @user.reload
        expect(@user.photo.present?).to eql(true)
      end
    end

    context 'with invalid tokens' do
      it 'updates the requested user' do
        @name = FFaker::Name.name
        put :update, params: { id: @user.id, user: @new_attributes }
        expect(response.status).to eql(401)
      end
    end
  end

  describe 'GET #wishist' do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      request.env['HTTP_ACCEPT'] = 'application/json'
      @new_attributes = { name: FFaker::Name.name }
    end

    context 'with valid params and tokens' do
      before do
        # Aqui nós estamos colocando no header os tokens (Sem isso a chamada seria bloqueada)
        request.headers.merge!(@auth_headers)
        @wishlist = create(:wishlist, user: @user)
        @wishlist2 = create(:wishlist, user: @user)
      end

      it 'get a list with two properties' do
        get :wishlist
        expect(JSON.parse(response.body).count).to eql(2)
      end
    end

    context 'with invalid params and tokens' do
      before do
        @wishlist = create(:wishlist, user: @user)
        @wishlist2 = create(:wishlist, user: @user)
      end

      it 'get a status 401' do
        get :wishlist
        expect(response.status).to eql(401)
      end
    end
  end
  
  after(:all) do
    # clean the directory with the uploaded images
    FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/user/photo/[^.]*"])
  end
end
