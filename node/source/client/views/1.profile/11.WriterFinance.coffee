class views.WriterFinance extends View
  events:
    'click #writer-filter': 'filter'
    'click #writer-csv': 'getCSV'

  filter: (e, render = true) ->
    if e
      e.preventDefault()
      e.stopPropagation()

    @context.from = @$("#writer_from").text() or "none"
    @context.to = @$("#writer_to").text() or "none"
    @context.active_tab = "writer-finance"
    @context.writer_filter = @$("#writer_filter").text()

    if render
      @render()

    data = "Client,Paid,Pending\n"
    _.each(@context.finance_writer, (finance) =>
      paid = 0
      pending = 0
      _.each(finance.runways, (runway) =>
        m = moment(runway.date)
        f = moment(@context.from)
        t = moment(@context.to)
        if @context.from != "none" && @context.to != "none" && !((m.isAfter(f, 'day') || m.isSame(f, 'day')) && (m.isBefore(t, 'day')) || m.isSame(t, 'day'))
          return
        if runway.paid
          paid += runway.charged
        else
          pending += runway.charged
      )

      data += "#{finance.writer.name},#{paid},#{pending}\n"
    )

    window.URL = window.webkitURL || window.URL;
    a = document.getElementById "writer-csv"

    return unless a?

    if a.href
      window.URL.revokeObjectURL(a.href)
    unless a.dataset?
      a.dataset = {}

    bb = new Blob([data], {type: "text/csv"});

    a.download = "Writer finance report for #{@context.writer_filter}.csv"
    a.href = window.URL.createObjectURL(bb)
    a.dataset.downloadurl = ["text/csv", a.download, a.href].join(':')

  initialize: (context) ->
    super context

    @listenTo @collection, "sync", @render
    @context.from = "none"
    @context.to = "none"

  render: ->
    @context.finance_writer = @collection.toJSON()
    html = tpl['member/writer_finance'](@context)
    @$el.html html
    options = views.DateRangeObject
    options.element = @$el
    @$('.daterange').daterangepicker options, _.bind(views.DateRangeFunction, @)
    @filter(null, false)
    @