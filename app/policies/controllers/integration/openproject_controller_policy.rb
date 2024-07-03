# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

class Controllers::Integration::OpenprojectControllerPolicy < Controllers::ApplicationControllerPolicy
    permit! %i[query update], to: 'ticket.agent'
    permit! :verify, to: 'admin.integration.openproject'
    default_permit!(['agent.integration.openproject', 'admin.integration.openproject'])
  end
  