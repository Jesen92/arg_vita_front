class ClientsController < ApplicationController
  before_filter :set_user, :set_cart
  def show
    @user = User.find(current_user)
  end
end
