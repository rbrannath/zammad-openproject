class SidebarOpenproject extends App.Controller
  sidebarItem: =>
    return if !@Config.get('openproject_integration')

    isAgentTicketZoom   = (@ticket and @ticket.currentView() is 'agent')
    isAgentTicketCreate = (!@ticket and @taskKey and @taskKey.match('TicketCreateScreen-'))

    return if !isAgentTicketZoom and !isAgentTicketCreate

    @item = {
      name: 'openproject'
      badgeIcon: 'checkmark'
      sidebarHead: __('Openproject')
      sidebarCallback: @showObjects
      sidebarActions: [
        {
          title:    __('Change Objects')
          name:     'objects-change'
          callback: @changeObjects
        },
      ]
    }
    @item

  changeObjects: =>
    new AppOpenprojectObjectSelector(
      taskKey: @taskKey
      container: @el.closest('.content')
      callback: (objectIds, objectSelectorUi) =>
        if @ticket && @ticket.id

          # add new objectIds to list of all @objectIds
          # and transfer the complete list to the backend
          @objectIds = @objectIds.concat(objectIds)

          @updateTicket(@ticket.id, @objectIds, =>
            objectSelectorUi.close()
            @showObjectsContent(objectIds)
          )
          return
        objectSelectorUi.close()
        @showObjectsContent(objectIds)
    )

  showObjects: (el) =>
    @el = el

    # show placeholder
    @objectIds ||= []
    if @ticket && @ticket.preferences && @ticket.preferences.openproject && @ticket.preferences.openproject.object_ids
      @objectIds = @ticket.preferences.openproject.object_ids
    queryParams = @queryParam()
    if queryParams && queryParams.openproject_object_ids
      @objectIds.push queryParams.openproject_object_ids
    @showObjectsContent()

  showObjectsContent: (objectIds) =>
    if objectIds
      @objectIds = @objectIds.concat(objectIds)

    # show placeholder
    # if _.isEmpty(@objectIds)
    #   @html("<div>#{App.i18n.translateInline('No tasks')}</div>")
    #   return

    # @html("<div>#{response.total}</div>")
    # ajax call to show items
    ticket_number = @ticket.number
    @ajax(
      id:    "openproject-#{@taskKey}"
      type:  'GET'
      url:   "#{@apiPath}/openproject_task?ticket_number=#{ticket_number}"
      success: (data, status, xhr) =>
        if data.response
          @showList(data.response.result, data.response.statuses, data.response.assignees, data.response.priorities, data.response.baseuri)
          return
        @showError(__('Loading failed.'))

      error: (xhr, status, error) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # show error message
        @showError(__('Loading failed.'))
    )

  showList: (objects, statuses, assignees, priorities, baseuri) =>
    list = $(App.view('ticket_zoom/sidebar_openproject')(
      objects: objects,
      statuses: statuses,
      assignees: assignees,
      priorities: priorities,
      baseuri: baseuri
    ))

    list.on('click', '.js-delete', (e) =>
      e.preventDefault()
      objectId = $(e.currentTarget).attr 'data-object-id'
      if @delete(objectId)
        $(e.currentTarget).closest('.sidebar-block').remove()
    )
    list.on('change', '.js-status', (e) =>
      e.preventDefault()
      objectId = $(e.currentTarget).attr 'data-object-id'
      selectedValue = $(e.currentTarget).val()
      @updateStatus(objectId, selectedValue)
    )
    list.on('change', '.js-assignee', (e) =>
      e.preventDefault()
      objectId = $(e.currentTarget).attr 'data-object-id'
      selectedValue = $(e.currentTarget).val()
      @updateAssignee(objectId, selectedValue)
    )
    list.on('change', '.js-priority', (e) =>
      e.preventDefault()
      objectId = $(e.currentTarget).attr 'data-object-id'
      selectedValue = $(e.currentTarget).val()
      @updatePriority(objectId, selectedValue)
    )
    @html(list)

  updateStatus: (objectId, selectedValue) =>

    App.Ajax.request(
      id:    "openproject-status-update-#{objectId}"
      type:  'PUT'
      url:   "#{@apiPath}/openproject_task_update_status"
      data:  JSON.stringify(task: objectId, status: selectedValue)
      success: (data, status, xhr) =>

        if data.response
          @notify
            type:    'success'
            msg:     App.i18n.translateContent('status_update_success')
            timeout: 4000        
          return
        @showError(__('Loading failed.'))

      error: (xhr, status, details) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # show error message
        @log 'errors', details
        @notify(
          type:    'error'
          msg:     App.i18n.translateContent(details.error_human || details.error || __('The object could not be updated.'))
          timeout: 6000
        )
    )
    
  updateAssignee: (objectId, selectedValue) =>

    App.Ajax.request(
      id:    "openproject-status-update-#{objectId}"
      type:  'PUT'
      url:   "#{@apiPath}/openproject_task_update_assignee"
      data:  JSON.stringify(task: objectId, assignee: selectedValue)
      success: (data, status, xhr) =>

        if data.response
          @notify
            type:    'success'
            msg:     App.i18n.translateContent('assignee_update_success')
            timeout: 4000        
          return
        @showError(__('Loading failed.'))

      error: (xhr, status, details) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # show error message
        @log 'errors', details
        @notify(
          type:    'error'
          msg:     App.i18n.translateContent(details.error_human || details.error || __('The object could not be updated.'))
          timeout: 6000
        )
    )

  updatePriority: (objectId, selectedValue) =>

    App.Ajax.request(
      id:    "openproject-status-update-#{objectId}"
      type:  'PUT'
      url:   "#{@apiPath}/openproject_task_update_priority"
      data:  JSON.stringify(task: objectId, priority: selectedValue)
      success: (data, status, xhr) =>

        if data.response
          @notify
            type:    'success'
            msg:     App.i18n.translateContent('priority_update_success')
            timeout: 4000        
          return
        @showError(__('Loading failed.'))

      error: (xhr, status, details) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # show error message
        @log 'errors', details
        @notify(
          type:    'error'
          msg:     App.i18n.translateContent(details.error_human || details.error || __('The object could not be updated.'))
          timeout: 6000
        )
    )

  delete: (objectId) =>

    App.Ajax.request(
      id:    "openproject-task-delete-#{objectId}"
      type:  'PUT'
      url:   "#{@apiPath}/openproject_task_delete"
      data:  JSON.stringify(task: objectId)
      success: (data, status, xhr) =>

        if data.response
          @sidebarItem
          @notify
            type:    'success'
            msg:     App.i18n.translateContent('task_delete_success')
            timeout: 4000        
          return true
        @showError(__('Loading failed.'))

      error: (xhr, status, details) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # show error message
        @log 'errors', details
        @notify(
          type:    'error'
          msg:     App.i18n.translateContent(details.error_human || details.error || __('The object could not be updated.'))
          timeout: 6000
        )
    )

  showError: (message) =>
    @html App.i18n.translateInline(message)

  reload: =>
    @showObjectsContent()

  postParams: (args) =>
    return if !args.ticket
    return if args.ticket.created_at
    return if !@objectIds
    return if _.isEmpty(@objectIds)
    args.ticket.preferences ||= {}
    args.ticket.preferences.openproject ||= {}
    args.ticket.preferences.openproject.object_ids = @objectIds

  updateTicket: (ticket_id, objectIds, callback) =>
    App.Ajax.request(
      id:    "openproject-update-#{ticket_id}"
      type:  'POST'
      url:   "#{@apiPath}/openproject_task"
      data:  JSON.stringify(ticket_id: ticket_id, object_ids: objectIds)
      success: (data, status, xhr) ->
        if callback
          callback(objectIds)

      error: (xhr, status, details) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # show error message
        @log 'errors', details
        @notify(
          type:    'error'
          msg:     App.i18n.translateContent(details.error_human || details.error || __('The object could not be updated.'))
          timeout: 6000
        )
    )

App.Config.set('500-Openproject', SidebarOpenproject, 'TicketCreateSidebar')
App.Config.set('500-Openproject', SidebarOpenproject, 'TicketZoomSidebar')