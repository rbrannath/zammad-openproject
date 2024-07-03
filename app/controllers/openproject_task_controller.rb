class OpenprojectTaskController < ApplicationController

  def index
    ticket_number = params[:ticket_number]
    Rails.logger.info "OpenProject Task Index called with ticket_number: #{ticket_number}"    # Geschäftslogik, um die Aufgabe basierend auf ticket_number zu finden
    openproject_service = OpenprojectService.new
    filter = [{ subject: { operator: "~", values: ["Ticket#" + ticket_number] } }].to_json
    response = openproject_service.get("work_packages", { filters: filter })
    if response
      elements = response.dig("_embedded", "elements")
      Rails.logger.info "Baseuri #{getBaseuri}"

    end
    # if task
    #   # Antwort mit den gefundenen Daten, wenn die Aufgabe existiert
    render json: { response: { result: elements, statuses: getStatus, assignees: getMembership, priorities: getPriorities, baseuri: getBaseuri } }
    # else
    #   # Antwort mit einer Fehlermeldung, wenn keine Aufgabe gefunden wurde
    # render json: { error: 'Task not found.' }, status: :not_found
    # end
  # end
    # model_index_render(OpenprojectTask, params)
  end

  def getBaseuri
    setting = Setting.find_by(name: 'openproject_config')
    raise 'OpenProject configuration not found' unless setting
    Rails.logger.info "Initalize"
    config = setting.state_current

    if config.is_a?(Hash)
      return URI(config['value']['endpoint'])
    else
      raise 'Expected state_current to be a Hash'
      return
    end
  end

  def show
    model_show_render(OpenprojectTask, params)
  end

  def create
    model_create_render(OpenprojectTask, params)
  end

  def updateAssignee

    openproject_service = OpenprojectService.new
    workPackage = getWorkPackage(params['task'])
    Rails.logger.info "Data: #{workPackage}"
    data = { _links: { assignee: { href: params['assignee']} }, lockVersion: workPackage.dig("lockVersion") }
    Rails.logger.info "Data: #{data}"
    response = openproject_service.patch("work_packages/#{params['task']}", data)
    if response
      elements = response.dig("_embedded")
      Rails.logger.info "Elemente: #{elements}"
    end

    render json: { response: { result: elements } }
  end

  def updateStatus

    openproject_service = OpenprojectService.new
    workPackage = getWorkPackage(params['task'])
    data = { _links: { status: { href: params['status']} }, lockVersion: workPackage.dig("lockVersion") }
    response = openproject_service.patch("work_packages/#{params['task']}", data)
    if response
      elements = response.dig("_embedded")
      Rails.logger.info "Elemente: #{elements}"
    end

    render json: { response: { result: elements } }
  end

  def updatePriority

    openproject_service = OpenprojectService.new
    workPackage = getWorkPackage(params['task'])
    data = { _links: { priority: { href: params['priority']} }, lockVersion: workPackage.dig("lockVersion") }
    Rails.logger.info "Data: #{data}"
    response = openproject_service.patch("work_packages/#{params['task']}", data)
    if response
      elements = response.dig("_embedded")
      Rails.logger.info "Elemente: #{elements}"
    end

    render json: { response: { result: elements } }
  end

  def deleteTask

    openproject_service = OpenprojectService.new
    workPackage = getWorkPackage(params['task'])
    response = openproject_service.delete("work_packages/#{params['task']}")

    render json: { response: { result: true } }
  end

  def destroy
    model_destroy_render(OpenprojectTask, params)
  end

  def getWorkPackage(id)
    openproject_service = OpenprojectService.new
    response = openproject_service.get("work_packages/#{id}")
    if response
      return response
    end 
  end

  def getWorkPackages(ticket_number)
    openproject_service = OpenprojectService.new
    filter = [{ subject: { operator: "~", values: ["Ticket#" + ticket_number] } }].to_json
    response = openproject_service.get("projects/3/work_packages", { filters: filter })
    if response
      elements = response.dig("_embedded", "elements")
    end
    return elements
  end

  def getStatus
    openproject_service = OpenprojectService.new
    # filter = [{ customField1: { operator: "=", values: ["Ticket#" + ticket_number] } }].to_json
    response = openproject_service.get("statuses")
    if response
      elements = response.dig("_embedded", "elements")
      allowed_statuses = ["New", "In progress", "Done", "On hold", "Rejected"]
      filtered_elements = elements.select do |obj|
        allowed_statuses.include?(obj["name"])
      end
      return filtered_elements
    end
    return
  end

  def getMembership
    openproject_service = OpenprojectService.new
    filter = [{ project: { operator: "=", values: 3 } }].to_json
    response = openproject_service.get("memberships", { filters: filter })
    if response
      elements = response.dig("_embedded", "elements")
    end
    return elements
  end

  def getPriorities
    openproject_service = OpenprojectService.new
    response = openproject_service.get("priorities")
    if response
      elements = response.dig("_embedded", "elements")
      return elements
    end
    return
  end

end
