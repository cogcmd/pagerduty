#!/usr/bin/env ruby

require_relative 'pagerduty'
require 'cog/command'
require 'pager_duty/connection'

class CogCmd::Pagerduty::Incidents < Cog::Command

  include CogCmd::Pagerduty

  def initialize
    @default_limit = 100
    @client = PagerDuty::Connection.new(account, token)
  end

  def run_command
    incidents = incidents(request).map do |incident|
      { id: incident.id,
        urgency: incident.urgency,
        summary: incident.trigger_summary_data,
        incident_key: incident.incident_key,
        created_on: incident.created_on,
        service: incident.service,
        url: incident.html_url,
        status: incident.status }
    end

    response.template = 'incidents'
    response.content = incidents
  end

  private

  def statuses(options)
    status_list = []
    status_list.push('triggered') if options["triggered"]
    status_list.push('resolved') if options["resolved"]
    status_list.push('acknowledged') if options["acked"]

    if status_list.length == 0
      status_list.push('triggered')
    end

    status_list.join(",")
  end

  def limit(limit)
    if limit
      limit
    else
      env_var("PAGERDUTY_DEFAULT_LIMIT", required: false) || @default_limit
    end
  end

  def services(service)
    resp = @client.get('services', query: service.join(" "))
    resp.services.map { |ser|
      ser.id
    }.join(",")
  end

  def incidents(request)
    opts = {
      status: statuses(request.options)
    }
    opts[:limit] = limit(request.options['limit']) if request.options['limit']
    opts[:service] = services(request.args) if request.args.length > 0

    resp = @client.get('incidents', opts)
    resp['incidents']
  end

end
