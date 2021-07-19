require 'spider/settings/user_agent'
require 'spider/agent/sanitizers'
require 'spider/agent/filters'
require 'spider/agent/events'
require 'spider/agent/actions'
require 'spider/agent/robots'
require 'spider/page'
require 'spider/session_cache'
require 'spider/cookie_jar'
require 'spider/auth_store'
require 'spider/spider'
require 'openssl'
require 'net/http'
require 'set'

module Spider
  class Agent

    include Settings::UserAgent

    attr_accessor :host_header

    attr_reader :host_headers

    attr_reader :default_headers

    attr_accessor :authorized

    attr_accessor :referer

    attr_accessor :delay

    attr_reader :history

    attr_reader :failures


    attr_reader :queue

    attr_reader :sessions

    attr_reader :cookies

    attr_reader :limit

    attr_reader :max_depth

    attr_reader :levels

    def initialize(options={})
      @host_header  = options[:host_header]
      @host_headers = {}

      if options[:host_headers]
        @host_headers.merge!(options[:host_headers])
      end

      @default_headers = {}

      if options[:default_headers]
        @default_headers.merge!(options[:default_headers])
      end

      @user_agent = options.fetch(:user_agent,Spider.user_agent)
      @referer    = options[:referer]

      @sessions   = SessionCache.new(options)
      @cookies    = CookieJar.new
      @authorized = AuthStore.new

      @running  = false
      @delay    = options.fetch(:delay,0)
      @history  = Set[]
      @failures = Set[]
      @queue    = []

      @limit     = options[:limit]
      @levels    = Hash.new(0)
      @max_depth = options[:max_depth]

      if options[:queue]
        self.queue = options[:queue]
      end

      if options[:history]
        self.history = options[:history]
      end

      initialize_sanitizers(options)
      initialize_filters(options)
      initialize_actions(options)
      initialize_events(options)

      if options.fetch(:robots,Spider.robots?)
        initialize_robots
      end

      yield self if block_given?
    end

    def self.start_at(url,options={},&block)
      agent = new(options,&block)
      agent.start_at(url)
    end

    
    def self.site(url,options={},&block)
      url = URI(url)

      agent = new(options.merge(host: url.host),&block)
      agent.start_at(url)
    end

    def self.host(name,options={},&block)
      agent = new(options.merge(host: name),&block)
      agent.start_at(URI::HTTP.build(host: name, path: '/'))
    end


    def proxy
      @sessions.proxy
    end

    def proxy=(new_proxy)
      @sessions.proxy = new_proxy
    end


    def clear
      @queue.clear
      @history.clear
      @failures.clear
      return self
    end


    def start_at(url,&block)
      enqueue(url)
      return run(&block)
    end


    def run(&block)
      @running = true

      until (@queue.empty? || paused? || limit_reached?)
        begin
          visit_page(dequeue,&block)
        rescue Actions::Paused
          return self
        rescue Actions::Action
        end
      end

      @running = false
      @sessions.clear
      return self
    end


    def running?
      @running == true
    end


    def history=(new_history)
      @history.clear

      new_history.each do |url|
        @history << URI(url)
      end

      return @history
    end

    alias visited_urls history


    def visited_links
      @history.map(&:to_s)
    end

    def visited_hosts
      visited_urls.map(&:host).uniq
    end

    def visited?(url)
      @history.include?(URI(url))
    end


    def failures=(new_failures)
      @failures.clear

      new_failures.each do |url|
        @failures << URI(url)
      end

      return @failures
    end


    def failed?(url)
      @failures.include?(URI(url))
    end

    alias pending_urls queue

    def queue=(new_queue)
      @queue.clear

      new_queue.each do |url|
        @queue << URI(url)
      end

      return @queue
    end

    def queued?(url)
      @queue.include?(url)
    end

    def enqueue(url,level=0)
      url = sanitize_url(url)

      if (!(queued?(url)) && visit?(url))
        link = url.to_s

        begin
          @every_url_blocks.each { |url_block| url_block.call(url) }

          @every_url_like_blocks.each do |pattern,url_blocks|
            match = case pattern
                    when Regexp
                      link =~ pattern
                    else
                      (pattern == link) || (pattern == url)
                    end

            if match
              url_blocks.each { |url_block| url_block.call(url) }
            end
          end
        rescue Actions::Paused => action
          raise(action)
        rescue Actions::SkipLink
          return false
        rescue Actions::Action
        end

        @queue << url
        @levels[url] = level
        return true
      end

      return false
    end

    def get_page(url)
      url = URI(url)

      prepare_request(url) do |session,path,headers|
        new_page = Page.new(url,session.get(path,headers))

        @cookies.from_page(new_page)

        yield new_page if block_given?
        return new_page
      end
    end


    def post_page(url,post_data='')
      url = URI(url)

      prepare_request(url) do |session,path,headers|
        new_page = Page.new(url,session.post(path,post_data,headers))

        @cookies.from_page(new_page)

        yield new_page if block_given?
        return new_page
      end
    end


    def visit_page(url)
      url = sanitize_url(url)

      get_page(url) do |page|
        @history << page.url

        begin
          @every_page_blocks.each { |page_block| page_block.call(page) }

          yield page if block_given?
        rescue Actions::Paused => action
          raise(action)
        rescue Actions::SkipPage
          return nil
        rescue Actions::Action
        end

        page.each_url do |next_url|
          begin
            @every_link_blocks.each do |link_block|
              link_block.call(page.url,next_url)
            end
          rescue Actions::Paused => action
            raise(action)
          rescue Actions::SkipLink
            next
          rescue Actions::Action
          end

          if (@max_depth.nil? || @max_depth > @levels[url])
            enqueue(next_url,@levels[url] + 1)
          end
        end
      end
    end


    def to_hash
      {history: @history, queue: @queue}
    end

    protected

    def prepare_request_headers(url)
      headers = @default_headers.dup

      unless @host_headers.empty?
        @host_headers.each do |name,header|
          if url.host.match(name)
            headers['Host'] = header
            break
          end
        end
      end

      headers['Host']     ||= @host_header if @host_header
      headers['User-Agent'] = @user_agent if @user_agent
      headers['Referer']    = @referer if @referer

      if (authorization = @authorized.for_url(url))
        headers['Authorization'] = "Basic #{authorization}"
      end

      if (header_cookies = @cookies.for_host(url.host))
        headers['Cookie'] = header_cookies
      end

      return headers
    end

    def prepare_request(url,&block)
      path = unless url.path.empty?
               url.path
             else
               '/'
             end

      path += "?#{url.query}" if url.query

      headers = prepare_request_headers(url)

      begin
        sleep(@delay) if @delay > 0

        yield @sessions[url], path, headers
      rescue SystemCallError,
             Timeout::Error,
             SocketError,
             IOError,
             OpenSSL::SSL::SSLError,
             Net::HTTPBadResponse,
             Zlib::Error

        @sessions.kill!(url)

        failed(url)
        return nil
      end
    end

    def dequeue
      @queue.shift
    end

    def limit_reached?
      @limit && @history.length >= @limit
    end

    def visit?(url)
      !visited?(url) &&
       visit_scheme?(url.scheme) &&
       visit_host?(url.host) &&
       visit_port?(url.port) &&
       visit_link?(url.to_s) &&
       visit_url?(url) &&
       visit_ext?(url.path) &&
       robot_allowed?(url.to_s)
    end

    def failed(url)
      @failures << url
      @every_failed_url_blocks.each { |fail_block| fail_block.call(url) }
      return true
    end

  end
end