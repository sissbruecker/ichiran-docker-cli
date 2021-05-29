# ichiran-docker-cli

The [Ichiran](https://github.com/tshatrov/ichiran) CLI packaged for usage with Docker.
About Ichiran (from the project homepage):
> Ichiran is a collection of tools for working with text in Japanese language. It contains experimental segmenting and romanization algorithms and uses open source JMdictDB dictionary database to display meanings of words.
 
In order to build the Ichiran CLI manually you would need to set up several tools as well as a Postgresql database. 
This project aims to simplify using the Ichiran CLI by providing a single Docker image that has all tools, as well as the database already set up, following the instructions provided [here](https://readevalprint.tumblr.com/post/639359547843215360/ichiranhome-2021-the-ultimate-guide).
The image already includes a fully seeded database based on the database dump provided by the Ichiran project itself, so the image is ready to go without requiring any further dependencies. 
Note that this convenience also comes with downsides: The data in the image can get stale if a new dump of the Ichiran DB is released, and the image is quite large (~5 GB uncompressed).

This is currently more of a proof-of-concept. The initial goal was to make using the CLI as simple as possible without requiring any further setup. It is not clear how this image would be utilized when writing an application that wants to make use of the Ichiran features.

## Usage

First, pull the image from Docker hub. As stated above, the image is quite large, so this may take a while:
```
docker pull sissbruecker/ichiran-cli:latest
```

Next start a container:
```
docker run -d --name ichiran-cli sissbruecker/ichiran-cli:latest
```
Note we are not starting a temporary container here, the container will keep running in the background until explicitly stopped. While this is untypical for CLI tools distributed through Docker, this is necessary because the Ichiran CLI requires the database to run, which is part of the container itself. 
You can stop the container with `docker stop ichiran-cli`, or remove it with `docker rm -f ichiran-cli`.

Finally, to run the actual CLI:
```
docker exec ichiran-cli /bin/sh -c "ichiran-cli -i \"一覧は最高だぞ\""
```
Please check the [original blog post](https://readevalprint.tumblr.com/post/639359547843215360/ichiranhome-2021-the-ultimate-guide) for more info about the CLI itself.


## Development

**Requirements**
- Docker
- Docker-compose

This project builds two Docker images:
- `sissbruecker/ichiran-db`: Based on the official Postgresql image, and adds an `ichiran` database with the imported Ichiran DB dump
- `sissbruecker/ichiran-cli`: Based on the above `sissbruecker/ichiran-db` image, and adds the compiled `ichiran-cli` executable

**Building the database image**

- Download the latest Ichiran database dump from the [Ichiran repository](https://github.com/tshatrov/ichiran)
- Copy `.env.template` to `.env` and set the `DB_DUMP_PATH` to the path where you downloaded the database dump
- Run `./build-database-image.sh` to build the image

What the build does:
- Builds the image in `images/database` and starts a container. The image at this point is a basic Postgresql image plus a script for creating the Ichiran database when the container starts, plus the database dump. 
- Imports the database dump into the created database - this needs to happen while the database is running, that's why this step can not be part of the Dockerfile itself
- Afterwards it does some cleanup and stops the database service
- Then creates the final database image from the container with the seeded database, and tags it

**Building the CLI image**

This requires the database image to be built first. Otherwise the build will pull an existing database image from Docker Hub.

- Run `./build-cli-image.sh` to build the image

What the build does:
- Builds the image in `images/cli` and starts a container. The image is the seeded database image, plus ichiran sources, plus dependencies required for building the Ichiran CLI.
- Runs the build script within the container - again this step needs to happen while the container is running, because the build requires a running database. Again, that's why this step can not be part of the Dockerfile itself.
- Then creates the final CLI image from the container with the build output, and tags it
