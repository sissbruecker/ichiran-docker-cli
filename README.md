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

**Building the image**

- Download the latest Ichiran database dump from the [Ichiran repository](https://github.com/tshatrov/ichiran)
- Download the dictionary `data` folder from the [jmdictdb](https://gitlab.com/yamagoya/jmdictdb/-/tree/master/jmdictdb/data) project and unzip into a folder
- Copy `.env.template` to `.env` and set the `DB_DUMP_PATH` to the path where you downloaded the database dump, and `JM_DICT_DB_PATH` to the folder where you unzipped the dictionary data
- Run `./build-image.sh` to build the image

What the build does:
- Builds a template image from the `Dockerfile` and starts a container. The image at this point is a basic Postgresql image plus:
  - a script for creating the Ichiran database when the container starts, and the database dump
  - Ichiran sources, settings, dictionary data
- Imports the database dump into the created database - this needs to happen while the database is running, that's why this step can not be part of the Dockerfile itself
- Runs the Ichiran build, which compiles the sources into an executable and also imports the dictionary data into the DB 
- Then creates the final image by committing the template container into a new image, and tags it
