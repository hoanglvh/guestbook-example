minikube_ip:=$(shell minikube ip)
cur_dir:=$(shell pwd)
docker.compile:
	docker run --rm -v $(cur_dir)/guestbook-go:/go/src/myapp -it -w /go/src/myapp golang:latest make
	docker build -t guestbook guestbook-go
docker.build:
	docker build -t guestbook guestbook-go
minikube.tag:
	docker tag guestbook:latest $(minikube_ip):5000/guestbook
minikube.push:
	docker push $(minikube_ip):5000/guestbook
