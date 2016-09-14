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
    users = get_users
    if users.length > 0 then
      get_services(users)
    else
      []
    end
  end

  def get_services(users)
    query = request.args.join(" ")
    response = @client.get('services', include: ['escalation_policy'], query: query)
    if response.nil? then
      []
    elsif response.has_key?("services") then
      response["services"].map do |service|
        {
          name: service.name,
          id: service.id,
          oncall: users.find do |user|
            user[:policy_ids].include?(service.escalation_policy.id)
          end.delete_if { |key, value| key == :policy_ids }
        }
      end
    else
      []
    end
  end

  def get_users
    users = @client.get('users/on_call')['users']
    if users.nil? then
      []
    else
      users.map do |user|
        {
          name: user.name,
          id: user.id,
          email: user.email,
          policy_ids: user.on_call.map { |oc| oc.escalation_policy.id }
        }
      end
    end
  end

end
