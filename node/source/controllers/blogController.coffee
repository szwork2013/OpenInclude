{get_models} = require '../conf'

[BlogPost] = get_models ["BlogPost"]

basic = require "./basicController"
marked = require "marked"
moment = require "moment"
_ = require "underscore"

class BlogController extends basic
  index: ->
    BlogPost.count({publish: true}, (result, count) =>
      query = BlogPost.find({publish: true}).sort("-date")
      if @get? and @get[0]
        query.skip(5 * (@get[0] - 1)).limit(5)
      else
        query.limit(5)
      query.exec((result, posts) =>
        unless result
          @context.title = "Blog"
          @context.posts = posts
          @context.moment = require "moment"
          if @get?
            @context.page = parseInt(@get[0])
          else
            @context.page = 1
          @context.limit = Math.ceil(count / 5)
          @context.body = @_view "blog/index", @context
          @res.render 'base', @context
        else
          @context.title = "Error"
          @context.body = "Error: #{result}"
          @res.render 'base', @context
      )
    )

  view: ->
    BlogPost.findById(@get[0], (result, post) =>
      unless result
        @context.title = post.title
        @context.post = post
        @context.moment = require "moment"
        @context.body = @_view "blog/post", @context
        @res.render 'base', @context
      else
        @context.title = "Error"
        @context.body = "Error: #{result}"
        @res.render 'base', @context
    )

module.exports = (req,res)->
  new BlogController req, res

module.exports.create = (req, res) ->
  req.body.author =
    id: req.user._id
    name: req.user.github_username
    avatar: req.user.github_avatar_url

  if req.body.date
    unless moment(req.body.date)
      delete req.body.date

  if req.body.tags
    req.body.tags = req.body.tags.split(",")
    req.body.tags = _.map(req.body.tags, (tag) ->
      return tag.trim()
    )

  post = new BlogPost(req.body)
  post.save((result, post) ->
    unless result
      res.json {success: true, post: post}
    else
      res.json {success: false, error: result}
  )

module.exports.list = (req, res) ->
  BlogPost.find().sort("-date").exec((result, posts) ->
    unless result
      res.json posts
    else
      res.json {success: false, error: result}
  )

module.exports.markdown = (req, res) ->
  res.send marked(req.body.data)