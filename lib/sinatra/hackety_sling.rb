require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/hackety_sling/post'

module Sinatra
  module HacketySling
    def self.registered(app)
      app.set :blog_posts_on_index, 2

      app.get '/' do
        @posts = Post.limit(app.blog_posts_on_index).all
        erubis :index
      end

      app.get '/archive/' do
        @posts = Post.order_by(:date => :desc).all
        erubis :post_list
      end

      %w(tags author).each do |attribute|
        app.get "/#{attribute}/:value/" do |value|
          @posts = Post.where(attribute.to_sym.include => value).all
          erubis :posts
        end
      end

      Post.all.each do |post|
        app.get post.permalink do
          @post = post
          erubis :post
        end
        base_name = post.file_name_without_extension.sub(/^\d{4}-\d{2}-\d{2}-/, '')
        app.get "/#{base_name}/" do
          redirect post.permalink, 301
        end
      end

      ymd = [:year, :month, :day]
      app.get %r{^/(\d{4}/)(\d{2}/)?(\d{2}/)?$} do
        selector_hash = {}
        params[:captures].each_with_index do |date_part, index|
          selector_hash[ymd[index]] = date_part.to_i unless date_part.nil?
        end
        @posts = Post.where(selector_hash).all
        erubis :posts
      end
    end
  end

  register HacketySling
end
