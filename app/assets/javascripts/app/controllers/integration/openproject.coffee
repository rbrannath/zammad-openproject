class Openproject extends App.ControllerIntegrationBase
  featureIntegration: 'openproject_integration'
  featureName: 'openproject'
  featureConfig: 'openproject_config'
  description: [
    [__('This service allows you to connect %s with %s.'), 'OpenProject', 'Zammad']
  ]
  events:
    'change .js-switch input': 'switch'

  render: =>
    super
    new Form(
      el: @$('.js-form')
    )

    new App.HttpLog(
      el: @$('.js-log')
      facility: 'openproject'
    )

class Form extends App.Controller
  elements:
    '.js-sslVerifyAlert': 'sslVerifyAlert'
  events:
    'change .js-sslVerify select': 'handleSslVerifyAlert'
    'submit form':                 'update'

  constructor: ->
    super
    @render()
    @handleSslVerifyAlert()

  currentConfig: ->
    App.Setting.get('openproject_config')

  setConfig: (value) ->
    App.Setting.set('openproject_config', value, {notify: true})

  render: =>
    @config = @currentConfig()

    verify_ssl = App.UiElement.boolean.render(
      name: 'verify_ssl'
      null: false
      default: true
      value: @config.verify_ssl
      class: 'form-control form-control--small'
    )

    content = $(App.view('integration/openproject')(
      config: @config
    ))

    content.find('.js-sslVerify').html verify_ssl

    @html content

  update: (e) =>
    e.preventDefault()
    @config = @formParam(e.target)
    @validateAndSave()

  validateAndSave: =>
    @ajax(
      id:    'openproject'
      type:  'POST'
      url:   "#{@apiPath}/integration/openproject/verify"
      data:  JSON.stringify(
        method: 'cmdb.object_types'
        api_token: @config.api_token
        endpoint: @config.endpoint
        client_id: @config.client_id
        verify_ssl: @config.verify_ssl
      )
      success: (data, status, xhr) =>
        if data.result is 'failed'
          new App.ErrorModal(
            message: data.message
            container: @el.closest('.content')
          )
          return
        @setConfig(@config)

      error: (data, status) =>

        # do not close window if request is aborted
        return if status is 'abort'

        details = data.responseJSON || {}
        @notify(
          type: 'error'
          msg:  App.i18n.translateContent(details.error_human || details.error || __('Saving failed.'))
        )
    )

  handleSslVerifyAlert: =>
    if @formParam(@el).verify_ssl
      @sslVerifyAlert.addClass('hide')
    else
      @sslVerifyAlert.removeClass('hide')

class State
  @current: ->
    App.Setting.get('openproject_integration')

App.Config.set(
  'IntegrationOpenproject'
  {
    name: 'openproject'
    target: '#system/integration/openproject'
    description: __('An open source project management.')
    controller: Openproject
    state: State
  }
  'NavBarIntegrations'
)
