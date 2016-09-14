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
    users = get_oncall_users
    services = get_services

    services.map do |service|
      oncalls = find_oncalls_for_service(service, users)

      {
        name: service.name,
        id: service.id,
        oncall: oncalls
      }
    end
  end

  def get_services
    query = request.args.join(" ")
    response = @client.get('services', include: ['escalation_policy'], query: query)
    response['services']
  end

  def get_oncall_users
    response = @client.get('users/on_call')
    users = response['users']

    users.map do |user|
      policy_ids = Array(user.on_call).map { |oc| oc.escalation_policy.id }

      {
        name: user.name,
        id: user.id,
        email: user.email,
        policy_ids: policy_ids
      }
    end
  end

  def find_oncalls_for_service(service, users)
    policy_id = service.escalation_policy.id
    oncalls = users.select { |u| u[:policy_ids].include?(policy_id) }

    oncalls.map do |user|
      Hash[user.reject { |key, _| key == :policy_ids }]
    end
  end
end
