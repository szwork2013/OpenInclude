class views.ReaderRunways extends View
  events:
    'click #alter-runway': 'alterRunway'

  alterRunway: (e) ->
    e.preventDefault()
    e.stopPropagation()

    suffix = e.currentTarget.attributes['rel'].value
    limit = parseInt(e.currentTarget.attributes['data-limit'].value)
    current = parseInt(e.currentTarget.attributes['data-current'].value)

    @button = $(e.currentTarget)
    @button.hide()

    model = @collection.get(suffix)

    @editForm = new views.AlterRunwayForm _.extend(@context, {limit: limit, model: model, current: current, el: "#alter-runway-inline-#{suffix}"})
    @listenTo @editForm, "success", @updateData
    @listenTo @editForm, "hidden", => @button.show()
    @editForm.show()

  updateData: ->
    @context.active_tab = "reader-runway"
    @collection.fetch()
    @button.show()

  initialize: (context) ->
    super context

    @listenTo @collection, "sync", @render

  render: ->
    @context.runways_reader = @collection.toJSON()
    html = tpl['member/reader_runway'](@context)
    @$el.html html
    @