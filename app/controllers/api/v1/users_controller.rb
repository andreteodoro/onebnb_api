class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!

  def current_user
    @user = current_api_v1_user
    render template: '/api/v1/users/show', status: 200
  end

  # GET /api/v1/users/:id/wishlist
  def wishlist
    @api_v1_properties = current_api_v1_user.wishlists.map(&:property)
    render template: '/api/v1/properties/index', status: 200
  end

  def update
    @user = current_api_v1_user
    if @user.update(user_params)
      render :show, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :nickname, :photo)
  end
end
