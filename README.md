# spider
A ruby web spidering tool that can spider a site, multiple domains, certain links or infinitely

[![forthebadge](https://forthebadge.com/images/badges/made-with-ruby.svg)](https://forthebadge.com)

# Installation
```
git clone https://github.com/krishpranav/spider
cd spider
bundle install
```

## Examples

Start spidering from a URL:
```rb
    spider.start_at('http://google.com/')
```

Spider a host:
```rb

    spider.host('google.com')
```

Spider a site:
```rb
    spider.site('http://www.rubyflow.com/')
```

Spider multiple hosts:
```rb

    spider.start_at(
      'http://company.com/',
      hosts: [
        'company.com',
        /host[\d]+\.company\.com/
      ]
    )
```

Do not spider certain links:
```rb
    spider.site('http://company.com/', ignore_links: [%{^/blog/}])
```

Do not spider links on certain ports:
```rb
    spider.site('http://company.com/', ignore_ports: [8000, 8010, 8080])
```

Do not spider links blacklisted in robots.txt:
```rb
    spider.site(
      'http://company.com/',
      robots: true
    )
```

Print out visited URLs:
```rb
    spider.site('http://www.rubyinside.com/') do |spider|
      spider.every_url { |url| puts url }
    end
```

Build a URL map of a site:
```rb
    url_map = Hash.new { |hash,key| hash[key] = [] }

    spider.site('http://intranet.com/') do |spider|
      spider.every_link do |origin,dest|
        url_map[dest] << origin
      end
    end
```

Print out the URLs that could not be requested:
```rb
    spider.site('http://company.com/') do |spider|
      spider.every_failed_url { |url| puts url }
    end
```

Finds all pages which have broken links:
```rb
    url_map = Hash.new { |hash,key| hash[key] = [] }

    spider = spider.site('http://intranet.com/') do |spider|
      spider.every_link do |origin,dest|
        url_map[dest] << origin
      end
    end

    spider.failures.each do |url|
      puts "Broken link #{url} found in:"

      url_map[url].each { |page| puts "  #{page}" }
    end
```

Search HTML and XML pages:
```rb
    spider.site('http://company.com/') do |spider|
      spider.every_page do |page|
        puts ">>> #{page.url}"

        page.search('//meta').each do |meta|
          name = (meta.attributes['name'] || meta.attributes['http-equiv'])
          value = meta.attributes['content']

          puts "  #{name} = #{value}"
        end
      end
    end
```

Print out the titles from every page:
```rb
    spider.site('https://www.ruby-lang.org/') do |spider|
      spider.every_html_page do |page|
        puts page.title
      end
    end
```

Find what kinds of web servers a host is using, by accessing the headers:
```rb
    servers = Set[]

    spider.host('company.com') do |spider|
      spider.all_headers do |headers|
        servers << headers['server']
      end
    end
```

Pause the spider on a forbidden page:
```rb
    spider.host('company.com') do |spider|
      spider.every_forbidden_page do |page|
        spider.pause!
      end
    end
```

Skip the processing of a page:
```rb
    spider.host('company.com') do |spider|
      spider.every_missing_page do |page|
        spider.skip_page!
      end
    end
```

Skip the processing of links:
```rb
    spider.host('company.com') do |spider|
      spider.every_url do |url|
        if url.path.split('/').find { |dir| dir.to_i > 1000 }
          spider.skip_link!
        end
      end
    end
```
