#!/usr/bin/env ruby

require_relative 'pagerduty'
require 'cog/command'
require 'pager_duty/connection'

class CogCmd::Pagerduty::Resolve < Cog::Command

  include CogCmd::Pagerduty

  def initialize
    @client = PagerDuty::Connection.new(account, token)
  end

  def run_command
    incident_ids = request.args

    if incident_ids.length == 0
      response['body'] = 'You must pass at least one incident to resolve.'
      return response
    end

    if user
      resolves = []
      incident_ids.each do |id|
        begin
          @client.put("incidents/#{id}/resolve", requester_id: user.id)
          resolves.push("Resolved #{id}")
        rescue PagerDuty::Connection::ApiError => error
          fail(error.inspect)
        end
      end
      response['body'] = resolves
    else
      fail("Couldn't find a user to make the request as.")
    end
  end

  private

  def user
    user_name = request.options["as"] || env_var("PAGERDUTY_EMAIL_FOR",
                                                 suffix: env_var("USER"),
                                                 required: false) ||
                                         env_var("PAGERDUTY_DEFAULT_EMAIL")
    @client.get('users', query: user_name)['users'].first if user_name
  end

end

