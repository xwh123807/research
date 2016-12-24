module DeployDoc
  class Config < Struct.new(:action, :markdown_file, :docker_socket, :docker_image, :data_dir)
    def self.defaults
      Config.new(nil, nil, "unix:///var/run/docker.sock", "ruby:2.3", ".")
    end
  end
end
