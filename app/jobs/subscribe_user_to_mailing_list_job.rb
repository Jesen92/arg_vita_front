class SubscribeUserToMailingListJob
  include SuckerPunch::Job

  def perform(user)
    gibbon = Gibbon::Request.new
    gibbon.lists("7c95b280f7").members.create( body: {email_address: user.email, status: "subscribed", FNAME: user.name,  :double_optin => false})
  end
  
end
