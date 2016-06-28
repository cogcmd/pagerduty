#!/usr/bin/env ruby

require_relative 'pagerduty'
require 'cog/command'
require 'pager_duty/connection'

class CogCmd::Pagerduty::Ack < Cog::Command

  include CogCmd::Pagerduty

  def initialize
    @client = PagerDuty::Connection.new(account, token)
  end

  def run_command
    incident_ids = request.args

    if incident_ids.length == 0
      response['body'] = 'You must pass at least one incident to acknowledge.'
      return response
    end

    if user
      acks = []
      incident_ids.each do |id|
        begin
          @client.put("incidents/#{id}/acknowledge", requester_id: user.id)
          acks.push("Acknowledged #{id}")
        rescue PagerDuty::Connection::ApiError => error
          fail(error.inspect)
        end
      end
      response['body'] = acks
    else
      fail("Couldn't find a user to make the request as.")
    end
  end
end
