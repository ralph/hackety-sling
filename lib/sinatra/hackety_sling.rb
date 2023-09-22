require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/hackety_sling/post'
require 'atom'

module Sinatra
  module HacketySling
    def self.registered(app)
      app.set :hackety_sling_posts_on_index, 2
      app.set :hackety_sling_title, nil
      app.set :hackety_sling_author, nil

      app.get '/' do
        limit = app.hackety_sling_posts_on_index
        @posts = Post.order_by(date: :desc).limit(limit).all
        erb :index
      end

      app.get '/archive/?' do
        @posts = Post.order_by(date: :desc).all
        erb :post_list
      end

      %w(tags author).each do |attribute|
        app.get "/#{attribute}/:value/?" do |value|
          @posts = Post.order_by(date: :desc)
          @posts = @posts.where(attribute.to_sym.include => value).all
          erb :posts
        end
      end

      Post.all.each do |post|
        app.get "#{post.permalink}?" do
          @post = post
          erb :post
        end
        base_name = post.file_name_without_extension.sub(/\d{4}-\d{2}-\d{2}-/, '')
        app.get "/#{base_name}/?" do
          redirect post.permalink, 301
        end
      end

      ymd = [:year, :month, :day]
      app.get %r{/(\d{4}/?)(\d{2}/?)?(\d{2}/?)?} do
        selector_hash = {}
        params[:captures].each_with_index do |date_part, index|
          selector_hash[ymd[index]] = date_part.to_i unless date_part.nil?
        end
        @posts = Post.order_by(date: :desc).where(selector_hash).all
        if @posts.length == 1
          redirect @posts.first.permalink, 301
        else
          erb :posts
        end
      end

      app.get '/atom.xml' do
        content_type 'application/atom+xml'
        feed = Atom::Feed.new do |f|
          f.title = app.hackety_sling_title ||= 'HacketySling Blog'
          blog_url = request.url.sub(request.fullpath, '/')
          f.links << Atom::Link.new(href: blog_url)
          f.links << Atom::Link.new(rel: 'self', href: request.url)
          f.updated = Post.last.date.xmlschema + 'T00:00:00+00:00'
          author = app.hackety_sling_author ||= app.hackety_sling_title
          f.authors << Atom::Person.new(name: author)
          f.id = blog_url
          Post.order_by(date: :desc).limit(10).all.each do |post|
            f.entries << Atom::Entry.new do |e|
              e.title = post.title
              e.links << Atom::Link.new(href: blog_url + post.permalink)
              e.id = blog_url + post.permalink
              e.content = Atom::Content::Html.new post.to_html
              e.updated = post.date.xmlschema + 'T00:00:00+00:00'
            end
          end
        end
        feed.to_xml.to_s
      end
    end
  end

  register HacketySling
end
