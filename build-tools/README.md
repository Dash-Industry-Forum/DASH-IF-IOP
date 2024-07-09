# Docker based setup

This folder contains the docker setup to create a container locally. The setup follows the regular docker build
structure with one caveat: we need to copy files from the folder below so we need to make sure that we pick the
right context. Check [build.sh](./build.sh) for a quick scrip to trigger a build from within this folder.

## Multi Platform Builds

Since we want to make the container available on multiple platforms, we need a slightly more advanced setup to
build. See [here](https://docs.docker.com/build/building/multi-platform/) for more information.

We start by creating a cross platform builder. Note that you only have to do this once:

```
docker buildx create --name crossbuilder --bootstrap --use
```

Now that we have the builder in place, we can create a multi-platform build:

```
docker build \
  --platform linux/amd64,linux/arm64 \
  --builder crossbuilder \
  -t dashif-test \
  -f ./Dockerfile \
  ../
```

Note that the command above need to be executed in this folder, otherwise you need to adjust the context (last
parameter) and the path to the `Dockerfile`.
