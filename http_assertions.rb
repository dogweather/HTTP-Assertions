# Author:: Robb Shecter.
# Copyright:: Copyright (c) 2009 Robb Shecter. All rights reserved.
# License:: Ruby license.    

module Test
  module Unit
    module Assertions
      
      ##
      # Asserts that +url1+ redirects to +url2+
      # with a status code of 302 or 307.
      
      public
      def assert_temp_redirect_to(url1, url2, message=nil)
        headers = head(url1)

        # Case 1: Not a 302 or 307 redirect.
        message = build_message message, "Expected a temp redirect (302 or 307) for <?> but got\n<?>.\n", url1, headers['Status']
        assert_block(message) { headers['Status'] =~ /^30[27]$/ }

        # Case 2: Not redirected to the right place.
        message = build_message message, "Expected a temp redirect to <?> but was to\n<?>.\n", url1, headers['Location']
        assert_block(message) { headers['Location'] == url2 }
      end
      
      ##
      # Passes if +url1+ redirects to +url2+ with 
      # status code 301.

      public
      def assert_perm_redirect_to(url1, url2, message=nil)
        headers = head(url1)

        # Case 1: Not a 301 redirect.
        message = build_message message, "Expected a permanent redirect (301) for <?> but got\n<?>.\n", url1, headers['Status']
        assert_block(message) { headers['Status'] == '301' }

        # Case 2: Not redirected to the right place.
        message = build_message message, "Expected a permanent redirect to <?> but was to\n<?>.\n", url1, headers['Location']
        assert_block(message) { headers['Location'] == url2 }
      end

      ##
      # Passes if the url can be successfully retrieved,
      # i.e. returns status code 200.
      
      public
      def assert_200(url, message=nil)
        assert_http_code('200', url, message)
      end

      ##
      # Passes if the url is forbidden; returns status
      # code 403.
      
      public
      def assert_403(url, message=nil)
        assert_http_code('403', url, message)
      end
      
      ##
      # Alias of assert_403.

      public 
      def assert_forbidden(url, message=nil)
        assert_403(url message)
      end

      ##
      # Assert that +url+ returns the given +status_code+.

      public
      def assert_http_code(status_code, url, message=nil)
        result  = head(url)['Status']
        message = build_message message, "<?> result code expected for <?> but got\n<?>.\n", status_code, url, result
        assert_block(message) { result == status_code }
      end

      ##
      # Test the given uri and return a hash populated
      # with the HTTP headers.  Handle the implementation
      # detail of the Status being communicated in two
      # different ways.
      
      private
      def head(uri)
        info   = {}
        output = `curl --silent --head --insecure #{uri}`
        for line in output.split("\n")
          if line =~ /^HTTP\/... (...)/
            key = 'Status'
            val = $1
            info[key] = val
          end
          next unless line =~ /^([^:]+): (.+)$/
          key = $1
          val = $2.strip
          info[key] = val
        end
        return info
      end
      
    end
  end
end
