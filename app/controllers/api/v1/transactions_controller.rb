class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_api_v1_user!

  def index
    @api_v1_transactions = current_api_v1_user.transactions
  end
end
