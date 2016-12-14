class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  after_save :subscribe_user_to_mailing_list

  after_create { |user|
    shopping = ShoppingCart.new

    shopping.user_id = user.id
    shopping.current_cost = 0
    shopping.save
  }

  validates :name, :address, :state, :postcode, :phone, presence: true

  private

  def subscribe_user_to_mailing_list
    SubscribeUserToMailingListJob.new.async.perform(self)
  end

  def send_welcome_email_to_user
    UserMailer.welcome_email(self).deliver_now
  end

end
