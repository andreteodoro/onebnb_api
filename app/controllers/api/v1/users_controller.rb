class Api::V1::UsersController < ApplicationController
    before_action :authenticate_api_v1_user!
    before_action :set_user, only: [:update]

    def update
        if @user.update(user_params)
            render :show, status: :ok
        else
            render json: @user.errors, status: :unprocessable_entity
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:name, :email, :nickname, :photo)
    end
end
