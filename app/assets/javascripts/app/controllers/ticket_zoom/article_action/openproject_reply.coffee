class OpenprojectReply
  @action: (actions, ticket, article, ui) ->
    return actions if !ticket.editable()
    return actions if ticket.currentView() is 'customer'

    actions.push {
      name: __('reply')
      type: 'openproject task'
      icon: 'reply'
      href: '#'
    }

    actions

  @perform: (articleContainer, type, ticket, article, ui) ->
    type = App.TicketArticleType.findByAttribute('name', 'openproject task')
    if type is 'openproject task'
      @openprojectAddtaskReply(ticket, article, ui)

    true

  @openprojectAddtaskReply: (ticket, article, ui) ->

    # get reference article
    type       = App.TicketArticleType.find(article.type_id)
    sender     = App.TicketArticleSender.find(article.sender_id)
    customer   = App.User.find(article.created_by_id)

    ui.scrollToCompose()

    # empty form
    articleNew = {
      to:          ''
      cc:          ''
      body:        ''
      in_reply_to: ''
    }

    if article.message_id
      articleNew.in_reply_to = article.message_id

    if sender.name is 'Agent'
      articleNew.to = article.to
    else
      articleNew.to = article.from

    # App.Event.trigger('ui::ticket::setArticleType', {
    #   ticket: ticket
    #   type: type
    #   article: articleNew
    # })

  @articleTypes: (articleTypes, ticket, ui) ->
    # return articleTypes if ticket.currentView() is 'customer'

    # return articleTypes if !ticket || !ticket.create_article_type_id

    articleTypeCreate = App.TicketArticleType.findByAttribute('name', 'openproject task')

    attributes = ['body:limit']
    articleTypes.push {
      name:              'openproject task'
      icon:              'checkmark'
      attributes:        ['to', 'subject']
      internal:          true,
      features:          attributes
      maxTextLength:     10000
      warningTextLength: 500
    }

    articleTypes

  @validation: (type, params, ui) ->
    if type is 'twitter status'
      textLength = ui.maxTextLength - App.Utils.textLengthWithUrl(params.body)
      return false if textLength < 0

    if params.type is 'twitter direct-message'
      textLength = ui.maxTextLength - App.Utils.textLengthWithUrl(params.body)
      return false if textLength < 0

      # check if recipient exists
      if _.isEmpty(params.to)
        new App.ControllerModal(
          head: __('Text missing')
          buttonCancel: __('Cancel')
          buttonCancelClass: 'btn--danger'
          buttonSubmit: false
          message: __('Need recipient in "To".')
          shown: true
          small: true
          container: ui.el.closest('.content')
        )
        return false

    true

  @setArticleTypePost: (type, ticket, ui) ->
    return if type isnt 'openproject task'
    rawHTML = ui.$('[data-name=body]').html()
    cleanHTML = App.Utils.htmlRemoveRichtext(rawHTML)
    if cleanHTML && cleanHTML.html() != rawHTML
      ui.$('[data-name=body]').html(cleanHTML)

  @params: (type, params, ui) ->
    # if type is 'twitter status'
    #   App.Utils.htmlRemoveRichtext(ui.$('[data-name=body]'), false)
    #   params.content_type = 'text/plain'
    #   params.body = App.Utils.html2text(params.body, true)

    # if type is 'twitter direct-message'
    #   App.Utils.htmlRemoveRichtext(ui.$('[data-name=body]'), false)
    #   params.content_type = 'text/plain'
    #   params.body = App.Utils.html2text(params.body, true)

    params

App.Config.set('300-OpenprojectReply', OpenprojectReply, 'TicketZoomArticleAction')
