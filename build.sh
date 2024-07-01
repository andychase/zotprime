DOCKER_BUILDKIT=1 docker build --progress=plain --file client.Dockerfile \
      --build-arg HOST_DS=http://localhost:8080/ \
      --build-arg HOST_ST=ws://localhost:8081/ \
      --build-arg MLW=w --output build .
