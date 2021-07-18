require 'uri'
require 'strscan'

module URI
  def self.expand_path(path)
    if path.start_with?('/')
      leading_slash, path = path[0,1], path[1..-1]
    else
      leading_slash = ''
    end

    if path.end_with?('/')
      trailing_slash, path = path[-1,1], path[0..-2]
    else
      trailing_slash = ''
    end

    scanner = StringScanner.new(path)
    stack   = []

    until scanner.eos?
      if (dir = scanner.scan(/^[^\/]+/))
        case dir
        when '..' then stack.pop
        when '.'  then false
        else           stack.push(dir)
        end
      else
        scanner.skip(/\/+/)
      end
    end

    unless stack.empty?
      "#{leading_slash}#{stack.join('/')}#{trailing_slash}"
    else
      '/'
    end
  end
end