require 'document_mapper'

module Sinatra
  module HacketySling
    class Post
      include DocumentMapper::Document

      self.directory = File.expand_path('../../../../test/test_posts', __FILE__)

      def permalink
        [
          self.date_permalink,
          self.file_name_without_extension.sub(/^\d{4}-\d{2}-\d{2}-/, '')
        ].join('') + '/'
      end

      def date_permalink
        '/' + ([
          sprintf("%04d", self.date.year),
          sprintf("%02d", self.date.month),
          sprintf("%02d", self.date.day)
        ].join '/') + '/'
      end
    end
  end
end
