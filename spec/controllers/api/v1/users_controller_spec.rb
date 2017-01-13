require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do

  describe "PUT #update" do
    before do
      @user = create(:user)
      @auth_headers = @user.create_new_auth_token
      @new_attributes = {name: FFaker::Name.name}
      # Setting the request as json (the URL users.json will be use instead of users)
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "with valid params and tokens" do
      before do
        # Merge the token into the Header
        request.headers.merge!(@auth_headers)
      end

      it "updates the requested user" do
        @name = FFaker::Name.name
        put :update, params: {id: @user.id, user: @new_attributes}
        @user.reload
        expect(@user.name).to eql(@new_attributes[:name])
      end
    end

    context "with invalid tokens" do
      it "updates the requested user" do
        @name = FFaker::Name.name
        put :update, params: {id: @user.id, user: @new_attributes}
        expect(response.status).to eql(401)
      end
    end
  end

end
