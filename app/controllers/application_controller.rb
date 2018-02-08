class ApplicationController < ActionController::Base
  include ApplicationHelper
  helper_method :resource_name, :resource, :devise_mapping, :resource_class
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_user, :set_cart, :set_article_raw_session

  def set_article_raw_session
    cookies[:article_raw] = nil
  end

  def set_user
    if current_user
      @user = current_user
    elsif $no_user_articles.blank? && $no_user_single_articles.blank?
      $no_user_articles = Hash.new
      $no_user_articles_int = Hash.new
      $no_user_single_articles = Hash.new
      $items_cost = 0
    end
  end

  def set_cart
    if current_user == nil
      #binding.pry
      @no_articles = Article.where(id: $no_user_articles.keys) unless $no_user_articles.blank?
      @sa = SingleArticle.where(id: $no_user_single_articles.keys) unless $no_user_single_articles.blank?
    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
      if @shopping_cart.current_cost < 0
        @shopping_cart.update(current_cost: 0)
      end
      discount = current_user.purchase_sum >= 500 ? ((current_user.purchase_sum/500).round*500)/100 : 0
      flash[:discount_notice] = discount > 0 ? '<span style="color: #348877;">Svojom vjernosti ostvarili ste popust od <span style="font-size: 150%; color: #515151;"> '+discount.to_s+'%</span> na sve artikle</span>' : nil
    end
  end

  def set_main_title
    @main_title = 'Argentum Vita'
  end

end

#### u layout-u za komplete kada se ubace

=begin
<% else %>

                        <li class="clearfix">
<%= link_to i.complement.title, complements_show_path(id: i.complement.id), class: "item-title" %>
                          <br/>
                          <% if i.complement.pictures.first != nil %>
<%=image_tag(i.complement.pictures.first.image.url(:table), class: "productimg") %>
                          <% elsif i.complement.article.picture != nil %>
<%=image_tag(i.complement.article.picture.image.url(:table), class: "productimg" ) %>
                          <% else %>
                              <%=image_tag("default-placeholder.png", class: "productimg" ) %>
<% end %>
    <!-- TODO napravi da se prikazuje slika od tocno tog single_article-a, a ne od cijelokupnog artikla -->
                                                                                                        <span class="item-price"><%=  number_to_currency(i.complement.cost, :unit => 'Kn', :format => "%n %u") %></span>
                          <span class="quantity"><%= i.amount %></span>
<%= link_to 'remove', destroy_complement_shopping_carts_path(i.complement.id), :method => :put, class: "quantity" %>
</li>
=end
