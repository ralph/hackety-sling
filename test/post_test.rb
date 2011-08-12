$:.push File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'minitest/spec'
require 'minitest/mock'
MiniTest::Unit.autorun

require 'sinatra/hackety_sling/post'
include Sinatra::HacketySling

describe Post do
  it 'should return the correct date permalink' do
    assert_equal '/2010/08/09/', Post.order_by(:title => :asc).first.date_permalink
  end

  it 'should return the correct permalink' do
    assert_equal '/2010/08/09/test-post-1/', Post.order_by(:title => :asc).first.permalink
  end
end
