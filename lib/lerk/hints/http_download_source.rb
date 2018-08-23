module Lerk
  module Hints
    class HTTPDownloadSource
      SHEET_DOWNLOAD_URL = 'https://docs.google.com/spreadsheets/d/1avfd3taTetnCofE9AZIJUd8Z3lyX6Y7EehZIu6dBfpw/gviz/tq?tqx=out:csv&sheet=Tip-List&headers=0'

      def initialize
        @logger = ::Lerk.logger
      end

      # Downloads ingame hints from Google docs.
      #
      # Returns CSV-formatted content of spreadsheet data.
      # Raises `RuntimeError` if downloading failed.
      def contents
        @logger.info "Downloading NS2 hints sheet from #{ SHEET_DOWNLOAD_URL }"
        request = Typhoeus::Request.new(SHEET_DOWNLOAD_URL, connecttimeout: 5, timeout: 20)
        request.run

        response = request.response

        if response.success?
          response.body
        elsif response.timed_out?
          abort_with_error 'Download timed out'
        elsif response.code == 404
          abort_with_error 'File not found'
        else
          abort_with_error "Non-success status code while downloading: #{ response.code }"
        end
      end

      private
      def abort_with_error(msg)
        @logger.error msg
        raise msg
      end
    end
  end
end
