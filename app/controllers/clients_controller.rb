class ClientsController < ApplicationController
  before_filter :set_user, :set_cart, :set_main_title
  def show
    @user = User.find(current_user)
  end
end
