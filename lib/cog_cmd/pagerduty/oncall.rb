#!/usr/bin/env ruby

require_relative 'pagerduty'
require 'cog/command'
require 'pager_duty/connection'

class CogCmd::Pagerduty::Oncall < Cog::Command

  include CogCmd::Pagerduty

  def initialize
    @client = PagerDuty::Connection.new(account, token)
  end

  def run_command
    resp = oncall
    if resp.length > 0
      response.template = 'oncall'
      response.content = resp
    else
      response.template = 'noresults'
      response['body'] = []
    end

  end

  private

  def oncall
    users = @client.get('users/on_call')['users'].map { |user, acc|
      {
        name: user.name,
        id: user.id,
        email: user.email,
        policy_ids: user.on_call.map { |oc| oc.escalation_policy.id }
      }
    }
    services = get_services

    services.map { |service|
      {
        name: service.name,
        id: service.id,
        oncall: users.find { |user|
          user[:policy_ids].include?(service.escalation_policy.id)
        }.delete_if { |key, value| key == :policy_ids }
      }
    }
  end

  def get_services
    query = request.args.join(" ")
    @client.get('services', include: ['escalation_policy'], query: query)['services']
  end

end
