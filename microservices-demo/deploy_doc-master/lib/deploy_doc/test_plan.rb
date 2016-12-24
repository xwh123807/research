module DeployDoc
  class TestPlan
    require_relative "test_plan/annotator_parser"

    PHASES = ["pre-install", "create-infrastructure", "run-tests", "destroy-infrastructure"]

    class Step < Struct.new(:source_name, :line_span, :shell)
      def full_name
        "#{source_name}:#{line_span.inspect}"
      end
    end

    def self.from_file(file_name)
      content = File.read(file_name)
      self.from_str(content, file_name)
    end

    def self.from_str(content, file_name="<unknown file>")
      metadata = self.parse_metadata(content, file_name)

      if metadata["deployDoc"] != true
        raise DeployDoc::Error.new("Markdown file #{file_name} does not have a 'deployDoc:true' metadatum")
      end

      annotations = AnnotationParser.parse(content, file_name)
      required_env_vars = (annotations.select { |a| a.kind == "require-env" }).map { |a| a.params }.flatten
      phases = self.phases_from_annotations(annotations)
      TestPlan.new(metadata, required_env_vars, phases)
    end

    def self.parse_metadata(content, file_name)
      metadata = content.split("---",3)[1]
      YAML.load(metadata)
    rescue
      raise Error.new("Could not parse metadata in #{file_name}")
    end

    def self.phases_from_annotations(annotations)
      phases = {}

      PHASES.each do |phase|
        phases[phase] = (annotations.select { |a| a.kind == phase }).map { |a| Step.new(a.source_name, a.line_span, a.content) }
      end

      phases
    end

    attr_reader :metadata
    attr_reader :required_env_vars
    attr_reader :steps_in_phases

    def initialize(metadata, required_env_vars, steps_in_phases)
      @metadata = metadata
      @required_env_vars = required_env_vars
      @steps_in_phases = steps_in_phases
    end

    def to_s
     parts = []
     parts << "Deployment test plan:"
     parts << ""
     parts << "Required environment parameters"

     @required_env_vars.each do |e|
       parts << "  - #{e}"
     end

     PHASES.each do |phase|
       parts << "Steps in phase #{phase}:"
       @steps_in_phases[phase].each do |step|
         parts << "- #{step.source_name}:#{step.line_span.inspect}"
         parts << step.shell
       end
     end

     parts.join("\n")
    end

    def missing_env_vars
      @required_env_vars.select { |e| ENV[e].nil? }
    end

    def to_json
      json = {}

      PHASES.each do |phase_name|
        json[phase_name] = []
        @steps_in_phases[phase_name].each do |step|
          json[phase_name].push({
            line_span: step.line_span.inspect, 
            shell: step.shell.strip
          })
        end
      end

      JSON.pretty_generate(json)
    end
  end
end
