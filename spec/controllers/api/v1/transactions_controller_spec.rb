require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  include Requests::JsonHelpers
  include Requests::HeaderHelpers

  describe 'GET #index' do
    before do
      @user = create(:user)
      request.headers.merge!(header_with_authentication(@user))
    end

    context 'User has two transactions' do
      before do
        @reservation1 = create(:reservation, status: :active, user: @user)
        @reservation2 = create(:reservation, status: :active, user: @user)

        @transaction1 = create(:transaction, user: @user, reservation: @reservation1)
        @transaction2 = create(:transaction, user: @user, reservation: @reservation2)
      end

      it 'receive two transactions' do
        get :index
        expect(json.count).to eql(2)
      end

      it 'Receive status 200' do
        get :index
        expect_status(200)
      end
    end

    context 'User has 0 transactions' do
      before do
        @reservation1 = create(:reservation, status: :active, user: @user)
        @reservation2 = create(:reservation, status: :active, user: @user)
      end
      
      it 'receive two transactions' do
        get :index
        expect(json.count).to eql(0)
      end
    end
  end
end
