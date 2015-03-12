module LanguageWorker
  class StyleGuideBase < Base
    def run
      hound_connection.post("/", body: hound_payload.to_json)
    end

    attr_implement :style_guide_name

    private

    def hound_payload
      {
        build_worker_id: build_worker.id,
        build_id: build_worker.build_id,
        violations: violations,
        file: {
          name: filename,
          content: content
        }
      }
    end

    def violations
      violations_from_guide.flat_map do |violation|
        {
          filename: violation.filename,
          line_number: violation.line_number,
          messages: violation.messages,
          build_id: build.id
        }
      end
    end

    def hound_connection
      @hound_connection ||= Faraday.new(url: ENV.fetch("BUILD_WORKERS_URL"))
    end

    def violations_from_guide
      @violations_from_guide ||= style_guide_name.new(
        repo_config,
        pull_request.repository_owner_name
      ).violations_in_file(commit_file)
    end
  end
end
