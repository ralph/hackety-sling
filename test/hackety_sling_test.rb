$:.push File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'sinatra/hackety_sling'
require 'minitest/spec'
require 'minitest/mock'
require 'rack/test'
MiniTest::Unit.autorun

require File.expand_path('../test_app', __FILE__)

ENV['RACK_ENV'] = 'test'

describe TestApp do
  include Rack::Test::Methods

  def app
    TestApp
  end

  before do
    @post_titles = Sinatra::HacketySling::Post.all.map(&:title)
  end

  describe 'when requesting the index path' do
    it 'should request the two most current posts' do
      get '/'
      assert last_response.ok?
      assert last_response.body.include? @post_titles[0]
      assert last_response.body.include? @post_titles[1]
      refute last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end
  end

  describe 'when requesting posts by time' do
    it 'should show all posts of one year' do
      get '/2010/'
      assert last_response.ok?
      assert last_response.body.include? @post_titles[0]
      assert last_response.body.include? @post_titles[1]
      assert last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end

    it 'should show all posts of one month' do
      get '/2010/11/'
      assert last_response.ok?
      refute last_response.body.include? @post_titles[0]
      refute last_response.body.include? @post_titles[1]
      assert last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end

    it 'should show all posts of one day' do
      get '/2010/08/10/'
      assert last_response.ok?
      refute last_response.body.include? @post_titles[0]
      assert last_response.body.include? @post_titles[1]
      refute last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end
  end

  describe 'when requesting a certain blog post' do
    it 'should show the blog post' do
      get '/2010/11/13/test-post-3/'
      assert last_response.ok?
      refute last_response.body.include? @post_titles[0]
      refute last_response.body.include? @post_titles[1]
      assert last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end

    it 'should redirect to the url with date if only the slug was given' do
      get '/test-post-2/'
      assert_redirected_to '/2010/08/10/test-post-2/', 301
    end
  end

  describe 'when requesting posts by tag' do
    it 'should show all posts with a certain tag' do
      get '/tags/ruby/'
      assert last_response.ok?
      assert last_response.body.include? @post_titles[0]
      assert last_response.body.include? @post_titles[1]
      refute last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end
  end

  describe 'when requesting posts by author' do
    it 'should show all posts with a certain author' do
      get '/author/ralph/'
      assert last_response.ok?
      refute last_response.body.include? @post_titles[0]
      refute last_response.body.include? @post_titles[1]
      assert last_response.body.include? @post_titles[2]
      refute last_response.body.include? @post_titles[3]
    end
  end

  describe 'when requesting the archive page' do
    it 'should respond to the archive path' do
      get '/archive/'
      assert last_response.ok?
      @post_titles.each do |post_title|
        assert last_response.body.include? post_title
      end
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
end

