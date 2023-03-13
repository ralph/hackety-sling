$:.push File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'minitest/autorun'
require 'sinatra/hackety_sling'
require 'rack/test'

require File.expand_path('../test_app', __FILE__)

ENV['RACK_ENV'] = 'test'

describe TestApp do
  include Rack::Test::Methods

  def app
    TestApp
  end

  before do
    @post_titles = Sinatra::HacketySling::Post.order_by(title: :asc).all.map(&:title)
  end

  describe 'when requesting the index path' do
    it 'displays the 2 most current posts by default' do
      app.set :hackety_sling_posts_on_index, 2
      get '/'
      assert last_response.ok?
      assert_equal ['Test post 5', 'Test post 4'], post_titles
    end

    it 'the number of posts is configurable' do
      app.set :hackety_sling_posts_on_index, 3
      get '/'
      assert last_response.ok?
      assert_equal ['Test post 5', 'Test post 4', 'Test post 2'], post_titles
      app.set :hackety_sling_posts_on_index, 2 # set back to original value
    end
  end

  describe 'when requesting posts by time' do
    it 'shows all posts of one year' do
      get '/2010/'
      assert last_response.ok?
      assert_equal ['Test post 4', 'Test post 2', 'Test post 3', 'Test post 1'], post_titles
    end

    it 'shows all posts of one month' do
      get '/2010/08/'
      assert last_response.ok?
      assert_equal ['Test post 2', 'Test post 3', 'Test post 1'], post_titles
    end

    it 'shows all posts of one day' do
      get '/2010/08/10/'
      assert last_response.ok?
      assert_equal ['Test post 2', 'Test post 3'], post_titles
    end

    it 'redirects to the post permalink if it is the only post' do
      get '/2010/08/09/'
      assert_redirected_to '/2010/08/09/test-post-1/', 301
    end
  end

  describe 'when requesting a certain blog post' do
    it 'shows the blog post' do
      get '/2010/11/13/test-post-4/'
      assert last_response.ok?
      assert_equal ['Test post 4'], post_titles
    end

    it 'redirects to the url with date if only the slug was given' do
      get '/test-post-1/'
      assert_redirected_to '/2010/08/09/test-post-1/', 301
    end
  end

  describe 'when requesting posts by tag' do
    it 'shows all posts with a certain tag' do
      get '/tags/ruby/'
      assert last_response.ok?
      assert_equal ['Test post 2', 'Test post 1'], post_titles
    end
  end

  describe 'when requesting posts by author' do
    it 'shows all posts with a certain author' do
      get '/author/ralph/'
      assert last_response.ok?
      assert_equal ['Test post 4'], post_titles
    end
  end

  describe 'when requesting the archive page' do
    it 'responds to the archive path' do
      get '/archive/'
      assert last_response.ok?
      @post_titles.each do |post_title|
        assert last_response.body.include? post_title
      end
    end
  end

  describe 'the atom feed' do
    it 'is generated ok' do
      get '/atom.xml'
      assert last_response.ok?
    end
  end

  def url(path)
    "http://example.org#{path}"
  end

  def assert_redirected_to(path, status = 301)
    redirect_url = last_response.headers['Location']
    status_msg = message(status_msg) { "Expected to be redirected with status #{status}, but was #{last_response.status}" }
    location_msg = message(location_msg) { "Expected to be redirected to #{path}, but was #{redirect_url}" }
    assert status == last_response.status, status_msg
    assert (path == redirect_url || url(path) == redirect_url), location_msg
  end

  def post_titles
    last_response.body.scan(/Test post \d/)
  end
end
