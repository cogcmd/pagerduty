`pagerduty`: The Cog PagerDuty Command Bundle
=========================================

# TL;DR

    !pagerduty:alert Customers complaining the site is down. Need help in #support
    !pagerduty:oncall
    !pagerduty:incidents
    !pagerduty:ack PHNRH53
    !pagerduty:resolve PHNRH53
![PagerDuty Command](https://raw.githubusercontent.com/cogcmd/pagerduty/master/pagerduty.gif)

PagerDuty Command: Finding out who is currently oncall
# Overview

The `pagerduty` bundle adds five new commands: ack, resolve, alert, incidents
and oncall.

* ack - Acknowledge triggered incidents
        `ack [-a | --as <pagerduty user email>] <incident id>`
        `ack` requires a pagerduty user's email address to acknowledge an
        incident. If `--as` is not passed ack will first look for an env
        var called `PAGERDUTY_EMAIL_FOR_<COG USER>` where `COG USER` is
        the Cog username for the user making the request. If that var
        isn't found it will fall back to `PAGERDUTY_DEFAULT_EMAIL`. If
        neither are found the command will fail.
* resolve - Resolve incidents
        `resolve [-a | --as <pagerduty user email>] <incident id>`
        `resolve` works identically to `ack`. First looking for
        `PAGERDUTY_EMAIL_FOR_<COG USER>` and then `PAGERDUTY_DEFAULT_EMAIL`.
* alert - Trigger an incident on a specific service.
        `alert [-s | --service <service name>] <msg>`
        Optionally you can set the `PAGERDUTY_DEFAULT_SERVICE_KEY` env var.
        `alert` will then trigger incidents on that service when no service
        is passed.
* incidents - Get a list of incidents
        `incidents [-a | --acked] [-t | --triggered] [-r | --resolved] [-l | --limit]`
        Get a list of incidents based on the option or options passed. By default
        incidents will return only incidents in the `triggered` state.
* oncall - Get a list of services with the current primary oncall
        `oncall [service name]`
        If a service is passed only the oncall for that service will be returned.
        Otherwise a list of services with their corresponding user will be returned.

# Permissions

pagerduty comes bundles with three permissions: pagerduty:alert, pagerduty:read,
pagerduty:write. By default `oncall` is 'allowed'. To `alert` you will need the
pagerduty:alert permission. To see incidents, pagerduty:read. And to `ack` or
`resolve`, pagerduty:write.

# Configuration

*The pager duty bundle still uses the v1 API. You'll need to select this when creating an account token.*

pagerduty uses a few env vars to configure it. All commands require
`PAGERDUTY_ACCOUNT_SUBDOMAIN` and `PAGERDUTY_ACCOUNT_TOKEN` to be set. That would
be the subdomain for your PagerDuty account and the api token respectively.

`alert` has an optional var, `PAGERDUTY_DEFAULT_SERVICE_KEY`. This is the integration
key found on the integration tab for the service on PagerDuty's web ui. If set, any
alerts that don't specify a service will be sent here. Note that if the service key
is not set or a service isn't passed to the command, it will fail.

`ack` and `resolve` have a couple extra vars. `PAGERDUTY_DEFAULT_EMAIL`, similar to
`PAGERDUTY_DEFAULT_SERVICE_KEY`, `ack` and `resolve` will use this email as the
requester when acking or resolving incidents. Additionally you may attach the
requester to cog accounts. Using vars in the form, `PAGERDUTY_EMAIL_FOR_<COG USER>`
you can specify which PagerDuty email is associated with which Cog user. So for
example, if your Cog username is 'bob', you would set the var `PAGERDUTY_EMAIL_FOR_BOB`.
Then whenever you `ack` or `resolve` the proper PagerDuty account is associated with the
action.

# Installing

    curl -O https://raw.githubusercontent.com/cogcmd/pagerduty/master/config.yaml
    cogctl bundle install config.yaml

# Building

To build the Docker image, simply run:

    $ rake image

Requires Docker and Rake.

