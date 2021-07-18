require 'uri'

module Spider
  class Agent

    attr_accessor :strip_fragments
    attr_accessor :strip_query

    def sanitize_url(url)
      url = URI(url)

      url.fragment = nil if @strip_fragments
      url.query    = nil if @strip_query

      return url
    end

    protected

    def initialize_sanitizers(options={})
      @strip_fragments = options.fetch(:strip_fragments,true)
      @strip_query     = options.fetch(:strip_query,false)
    end

  end
end