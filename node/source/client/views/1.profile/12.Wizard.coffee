class views.Wizard extends InlineForm
  el: "#tos"
  view: "member/wizard"

  events:
    'click .next,.prev': "dostep"
    'click .close-inline': "hideButton"

    'submit form': 'submit'

  dostep: (e) ->
    e.preventDefault()
    e.stopPropagation()

    step = e.currentTarget.attributes['rel'].value
    stepDiv = document.getElementById step
    if stepDiv
      $(@step).hide()
      @step = stepDiv
      $(@step).show()

      @$(".wizard-nav .active").last().next().addClass "active"

      console.log "step changed"

  submit: ->
    console.log "submit triggered"

    super

  initialize: (context) ->
    super context

  render: ->
    super()
    @step = document.getElementById "step-1"
    #@$(".content .content-wrapper").niceScroll()

  setType: (type) ->
    if @model
      @stopListening @model
      delete @model

    if type is "reader"
      @model     = new models.CreditCard
      @model.url = app.conf.update_credit_card
      @context.reader = true

    if type is "writer"
      @model = new models.CreditCard
      @model.url = "/profile/update_paypal"
      @context.reader = false