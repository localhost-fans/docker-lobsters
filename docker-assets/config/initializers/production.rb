class << Rails.application
  def domain
    ENV["LOBSTER_HOSTNAME"]
  end

  def name
    ENV["LOBSTER_SITE_NAME"]
  end

  def open_signups?
    ENV["OPEN_SIGNUPS"] == "true"
  end

  def allow_invitation_requests?
    false
  end

  def allow_new_users_to_invite?
    true
  end

  def ssl?
    false
  end
end

Rails.application.routes.default_url_options[:host] = Rails.application.domain

Lobsters::Application.config.secret_key_base = ENV["SECRET_KEY_BASE"]
