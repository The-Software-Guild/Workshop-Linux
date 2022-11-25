# Build Image / Run Container
- `docker compose up` or `docker compose up --build --force-recreate`
- If you want to add any packages to the container without installing them at run time, simply add the packages in the Dockerfile. It should be obvious where to add them, next to the packages already being installed with yum install.

# Enter Container via bash
- `docker exec -it awslinux2-container /bin/bash`
- Notice in home folder a dir named `share`", this is a shared volume between host and container. The host can access this dir through `awslinux2-volume`. Even if you delete the container or image, files in this folder will persist. 

# Stop Container
- `docker stop docker awslinux2-container`
- OR hit `ctrl+c` in the terminal running the docker compose up command
- You can start the container again with `docker compose up`  or `docker compose up --build --force-recreate`

# Cleanup
- note: If making changes to the docker image, you will need to delete the container and image. If you run docker compose up with the `--build --force-recreate` options, you will only need to delete the container.

## Delete Container
- `docker rm awslinux2-container`

## Delete Image
- `docker rmi awslinux2_awslinux2`
- note: The image is named after the directory it is in and the service name

## Delete the Volume
`docker volume rm awslinux2_awslinux2-volume`
- note: the volume is named after the dir it is in, and the name you give it in the docker compose file
- note: Deleteing the volume will note delete the dir on the host machine or files within it, it just deletes the mount within docker

