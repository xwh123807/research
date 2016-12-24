module DeployDoc
  module Docker
    def self.cmd(configuration, envs, cmd, extra_opts = [])
      data_dir = if configuration.data_dir == "."
                   Dir.pwd
                 else
                   configuration.data_dir
                 end

      docker_cmd = [
        "docker", 
        "run", 
        "-it",
        "--rm", 
        envs, 
        "-v#{data_dir}:/deploy_doc/data/",
        "-w/deploy_doc/data/"
      ]

      # Expose the host host docker daemon in the child docker container.
      docker_socket_protocol, docker_socket_address = configuration.docker_socket.split("://",2)
      case docker_socket_protocol
      when "unix"
        docker_cmd.push "-v#{docker_socket_address}:/var/run/docker.sock"
      when "tcp"
        docker_cmd.push "-e DOCKER_HOST='#{configuration.docker_socket}'"
      else
        raise DeployDocError.new("Unkown docker socket protocol '#{docker_socket_protocol}'")
      end

      docker_cmd += extra_opts
      docker_cmd += [configuration.docker_image, cmd]
      docker_cmd.join(" ")
    end
  end
end
