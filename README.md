# Guestbook Demo

This guestbook demo is an adaption of the guestbook of Kubernetes, so that it is isolated and run with docker-compose.

# Build

use `captain` to build the project:

```
captain build
```

or docker itself:

```
docker run --rm -v $(pwd)/guestbook-go:/go/src/myapp -it -w /go/src/myapp golang:latest make
docker build -t guestbook guestbook-go
```

# Run

```
docker-compose up -d
```

open http://DOCKER_HOST_IP:3000/
