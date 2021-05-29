#!/bin/bash

# Build and start template container
echo 'Starting CLI template container...'
docker-compose up -d --build cli
# Run build script
docker-compose exec -w '/var/lib/ichiran-cli' cli /bin/sh -c './build-cli.sh'
# Stop postgresql service to prevent database corruption
docker-compose stop cli
# Create image from CLI container
echo 'Writing final CLI image...'
docker commit ichiran-cli-docker_cli_1 sissbruecker/ichiran-cli:latest # Container name is hard-coded for now to match name generated by docker-compose