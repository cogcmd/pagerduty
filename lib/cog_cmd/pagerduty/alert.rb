#!/usr/bin/env ruby

require_relative 'pagerduty'
require 'cog/command'
require 'pager_duty/connection'
require 'pagerduty'

class CogCmd::Pagerduty::Alert < Cog::Command

  include CogCmd::Pagerduty

  def initialize
    @client = PagerDuty::Connection.new(account, token)
    @event = Pagerduty.new(service_key)
  end

  def run_command
    msg = request.args.join(" ")

    begin
      @event.trigger(msg)
      response['body'] = "Alert sent"
    rescue Net::HTTPServerException => error
      error = <<-END.gsub(/^ {7}/, '')
        \nError triggering incident:
        #{error.response.code}:#{error.response.message}
        #{error.response.body}
      END
      fail(error)
    end
  end

  def service_key
    service_name = request.options['service']
    if service_name
      @client.get('services', query: service_name)['services'].first['service_key']
    else
      env_var("PAGERDUTY_DEFAULT_SERVICE_KEY", required: true)
    end
  end

end
