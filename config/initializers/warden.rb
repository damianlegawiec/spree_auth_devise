# Merges users orders to their account after sign in and sign up.
Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  if auth.cookies.signed[:guest_token].present?
    if user.is_a?(Spree::User)
      # 10/27/15 - Spree 2.4 Upgrade for Mack Weldon
      # Removed email: user.email from where statement
      # This caused the error when a user (without logging in) adds to cart
      # and by then logging in, their cart would be empty
      # https://www.pivotaltracker.com/story/show/106111060
      Spree::Order.where(guest_token: auth.cookies.signed[:guest_token], user_id: nil).each do |order|
        order.associate_user!(user)
      end
    end
  end
end

Warden::Manager.before_logout do |user, auth, opts|
  auth.cookies.delete :guest_token
end
