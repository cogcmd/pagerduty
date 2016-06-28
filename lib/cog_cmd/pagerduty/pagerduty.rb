#!/usr/bin/env ruby

require 'cog/command'
require 'pager_duty/connection'

module CogCmd::Pagerduty

  def account
    env_var("PAGERDUTY_ACCOUNT_SUBDOMAIN", required: true)
  end

  def token
    env_var("PAGERDUTY_ACCOUNT_TOKEN", required: true)
  end

  def user
    user_name =
      request.options["as"] ||
      env_var("PAGERDUTY_EMAIL_FOR",
              suffix: env_var("COG_CHAT_HANDLE"),
              required: false) ||
      env_var("PAGERDUTY_DEFAULT_EMAIL")

    @client.get('users', query: user_name)['users'].first if user_name
  end

end
