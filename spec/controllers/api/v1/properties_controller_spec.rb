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
        @new_attributes = { title: FFaker::Name.name, description: FFaker::Name.name }
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
        @new_attributes = { title: FFaker::Name.name }
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
        end.to change(Api::V1::Property, :count).by(-1)
        expect(response.status).to eql(204)
      end
    end
  end
end
