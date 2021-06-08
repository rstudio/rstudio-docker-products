# Connect Content Init Container

This directory contains a Dockerfile and script that will create a "copy
container" to copy runtime components from a release package into a target
mount directory. This container can be used as an "init container" to pull the
runtime components into another image, which can then be used with Connect and
Launcher to build/run content.

## building

Make will build an image using a default Connect distribution.

```console
make build
```

The version of the release package to use can be overridden with the
`RSC_VERSION` build arg.

```console
RSC_VERSION=1.8.8.3-dev236 make build
```

## testing

You can observe what gets copied by the container:

```console
mkdir rstudio-connect-runtime
docker run --rm -v $(pwd)/rstudio-connect-runtime:/mnt/rstudio-connect-runtime rstudio/rstudio-connect-content-init-preview:1.8.8.3-dev236
# The rstudio-connect-runtime directory has been populated with the Connect
# runtime components.
```


## inspection

You can see the different layers that make up the image:

    docker history rstudio/rstudio-connect-content-init-preview:1.8.8.3-dev236

NOTE: almost all of the image size is pandoc.
