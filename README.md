# Hackety Sling

![http://travis-ci.org/ralph/hackety_sling](http://travis-ci.org/ralph/hackety_sling.png)

Hackety Sling is a very simple blog software based on [Sinatra](http://github.com/sinatra/sinatra) and [Document Mapper](http://github.com/ralph/document_mapper). It will add the following pages to your Sinatra application:

* An index page ('/'), showing 2 posts by default
* Posts by year/month/day, e.g. '/2010/08/10/', '/2010/08/' or '/2010/'
* Showing a single post, e.g.: '/2010/11/13/my-post/'
* Showing posts by tag, e.g.: '/tags/ruby/'
* Showing posts by author, e.g.: '/author/ralph/'
* An archive page: '/archive/'
* An atom feed: '/atom.xml'


Getting Hackety Sling to play nice with your existing Sinatra Application is easy. Just include the module and add some configuration settings, like in the example below:

```ruby
class MySuperBlog < Sinatra::Base
  register Sinatra::HacketySling

  set :hackety_sling_title, 'My super blog | A blog about stuff'
  set :hackety_sling_author, 'Carlos Testuser'


  # Optional
  set :hackety_sling_posts_on_index

  get '/other-sinatra-page/' do
    erubis :other-sinatra-page
  end
end
```

## Author

Written by [Ralph von der Heyden](http://www.rvdh.de). Don't hesitate to contact me if you have any further questions.

Follow me on [Twitter](http://twitter.com/ralph)
