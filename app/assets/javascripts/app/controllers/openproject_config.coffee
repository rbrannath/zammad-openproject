class OpenprojectConfig extends App.ControllerSubContent
  @requiredPermission: 'admin.openproject'
  header: __('OpenProject Config')

  constructor: ->
    super

    @genericController = new App.ControllerGenericIndex(
      el: @el
      id: @id
      genericObject: 'OpenprojectConfig'
      defaultSortBy: 'name'
      pageData:
        home: 'openproject_config'
        object: __('OpenProject')
        objects: __('OpenProject')
        pagerAjax: true
        pagerBaseUrl: '#manage/openproject_config/'
        pagerSelected: ( @page || 1 )
        pagerPerPage: 150
        navupdate: '#openproject_config'
        notes: [
          __('Manage openproject_config')
        ]
        buttons: [
          { name: __('New Configuration'), 'data-type': 'new', class: 'btn--success' }
        ]
      container: @el.closest('.content')
    )

  show: (params) =>
    for key, value of params
      if key isnt 'el' && key isnt 'shown' && key isnt 'match'
        @[key] = value

    @genericController.paginate( @page || 1 )

App.Config.set('OpenprojectConfig', { prio: 3300, name: __('OpenprojectConfig'), parent: '#manage', target: '#manage/openproject_config', controller: OpenprojectConfig, permission: ['admin.openproject'] }, 'NavBarAdmin')