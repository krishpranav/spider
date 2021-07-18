require 'spider/rules'

module Spider
  class Agent

    attr_reader :schemes

    def schemes=(new_schemes)
      @schemes = new_schemes.map(&:to_s)
    end

    def visit_hosts
      @host_rules.accept
    end

    def visit_hosts_like(pattern=nil,&block)
      if pattern
        visit_hosts << pattern
      elsif block
        visit_hosts << block
      end

      return self
    end

    def ignore_hosts
      @host_rules.reject
    end

    def ignore_hosts_like(pattern=nil,&block)
      if pattern
        ignore_hosts << pattern
      elsif block
        ignore_hosts << block
      end

      return self
    end

    def visit_ports
      @port_rules.accept
    end


    def visit_ports_like(pattern=nil,&block)
      if pattern
        visit_ports << pattern
      elsif block
        visit_ports << block
      end

      return self
    end


    def ignore_ports
      @port_rules.reject
    end

    def ignore_ports_like(pattern=nil,&block)
      if pattern
        ignore_ports << pattern
      elsif block
        ignore_ports << block
      end

      return self
    end

    def visit_links
      @link_rules.accept
    end


    def visit_links_like(pattern=nil,&block)
      if pattern
        visit_links << pattern
      elsif block
        visit_links << block
      end

      return self
    end

    def ignore_links
      @link_rules.reject
    end


    def ignore_links_like(pattern=nil,&block)
      if pattern
        ignore_links << pattern
      elsif block
        ignore_links << block
      end

      return self
    end

    def visit_urls
      @url_rules.accept
    end

    def visit_urls_like(pattern=nil,&block)
      if pattern
        visit_urls << pattern
      elsif block
        visit_urls << block
      end

      return self
    end


    def ignore_urls
      @url_rules.reject
    end


    def ignore_urls_like(pattern=nil,&block)
      if pattern
        ignore_urls << pattern
      elsif block
        ignore_urls << block
      end

      return self
    end

    def visit_exts
      @ext_rules.accept
    end

    def visit_exts_like(pattern=nil,&block)
      if pattern
        visit_exts << pattern
      elsif block
        visit_exts << block
      end

      return self
    end


    def ignore_exts
      @ext_rules.reject
    end

    def ignore_exts_like(pattern=nil,&block)
      if pattern
        ignore_exts << pattern
      elsif block
        ignore_exts << block
      end

      return self
    end

    protected

    def initialize_filters(options={})
      @schemes = []

      if options[:schemes]
        self.schemes = options[:schemes]
      else
        @schemes << 'http'

        begin
          require 'net/https'

          @schemes << 'https'
        rescue Gem::LoadError => e
          raise(e)
        rescue ::LoadError
          warn "Warning: cannot load 'net/https', https support disabled"
        end
      end

      @host_rules = Rules.new(
        accept: options[:hosts],
        reject: options[:ignore_hosts]
      )
      @port_rules = Rules.new(
        accept: options[:ports],
        reject: options[:ignore_ports]
      )
      @link_rules = Rules.new(
        accept: options[:links],
        reject: options[:ignore_links]
      )
      @url_rules = Rules.new(
        accept: options[:urls],
        reject: options[:ignore_urls]
      )
      @ext_rules = Rules.new(
        accept: options[:exts],
        reject: options[:ignore_exts]
      )

      if options[:host]
        visit_hosts_like(options[:host])
      end
    end


    def visit_scheme?(scheme)
      if scheme
        @schemes.include?(scheme)
      else
        true
      end
    end

    def visit_host?(host)
      @host_rules.accept?(host)
    end

    def visit_port?(port)
      @port_rules.accept?(port)
    end

    def visit_link?(link)
      @link_rules.accept?(link)
    end

    def visit_url?(link)
      @url_rules.accept?(link)
    end


    def visit_ext?(path)
      @ext_rules.accept?(File.extname(path)[1..-1])
    end

  end
end