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

end
