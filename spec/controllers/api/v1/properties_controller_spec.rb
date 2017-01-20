require 'rails_helper'

RSpec.describe Api::V1::PropertiesController, type: :controller do
  before do
    # Setting the request as json (the URL properties.json will be use instead of users)
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'GET #index' do
    context 'whith valid params' do
      it 'gets the properties' do
        get :index
        expect(response.status).to eql(200)
      end
    end
  end

  describe 'GET #show' do
    before do
      @property = create(:property)
    end

    context 'whith valid params' do
      it 'show the property' do
        get :show, params: { id: @property.id }
        expect(response.status).to eql(200)
      end
    end
  end

  describe 'POST #create' do
    context 'whith valid params' do
      it 'creates the requested user' do
        @new_attributes = { title: FFaker::Lorem.word, description: FFaker::Lorem.paragraph }
        post :create, params: { api_v1_property: @new_attributes }
        expect(response.status).to eql(201)
      end
    end
  end

  describe 'PUT #update' do
    before do
      @property = create(:property)
    end

    context 'whith valid params' do
      it 'updates the requested user' do
        @new_attributes = { name: FFaker::Lorem.word }
        put :update, params: { id: @property.id, api_v1_property: @new_attributes }
        @property.reload
        expect(@property.title).to eql(@new_attributes[:title])
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      @property = create(:property)
    end

    context 'whith valid params' do
      it 'deletes the requested user' do
        expect do
          delete :destroy, params: { id: @property.id }
        end.to change(Property, :count).by(-1)
        expect(response.status).to eql(204)
      end
    end
  end

  describe "POST #wishlist" do
    before do
      @user = create(:user)
      @property = create(:property)

      @auth_headers = @user.create_new_auth_token
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "with valid params and tokens" do
      before do
        request.headers.merge!(@auth_headers)
      end

      it "add to wishlist" do
        post :add_to_wishlist, params: {id: @property.id}
        @property.reload
        expect(@property.wishlists.last.id).to eql(Wishlist.last.id)
      end
    end

    context "with invalid tokens" do
      it "can't add to wishlist" do
        post :add_to_wishlist, params: {id: @property.id}
        expect(response.status).to eql(401)
      end
    end
  end

  describe "DELETE #wishlist" do
    before do
      @user     = create(:user)
      @property = create(:property)
      @wishlist = create(:wishlist, user: @user, property: @property)

      @auth_headers = @user.create_new_auth_token
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "with valid params and tokens" do
      before do
        request.headers.merge!(@auth_headers)
      end

      it "remove from wishlist" do
        delete :remove_from_wishlist, params: {id: @property.id}
        expect(Wishlist.all.count).to eql(0)
      end
    end

    context "with invalid tokens" do
      it "can't add to wishlist" do
        delete :remove_from_wishlist, params: {id: @property.id}
        expect(response.status).to eql(401)
      end

      it "whishlist keep existing" do
        delete :remove_from_wishlist, params: {id: @property.id}
        expect(Wishlist.all.count).not_to eql(0)
      end
    end
  end
end
