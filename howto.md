 
Checkout https://github.com/pilgrim2go/guestbook-example



 compile

 make docker.compile


Up and running

docker-compose up -d

Testing

curl localhost:3000

Cleanup

docker-compose down

Lesson Learnt

Use Makefile
Use Docker to compile Go project

----

Kubectl

Minikube

Kompose


Setup Minikube

Convert docker-compose to Kube resources

mkdir kubernetes
cd kubernetes
kompose convert -f ../docker-compose.yml

```
 kompose convert -f ../docker-compose.yml
INFO Kubernetes file "guestbook-service.yaml" created 
INFO Kubernetes file "redis-master-service.yaml" created 
INFO Kubernetes file "redis-slave-service.yaml" created 
INFO Kubernetes file "guestbook-deployment.yaml" created 
INFO Kubernetes file "redis-master-deployment.yaml" created 
INFO Kubernetes file "redis-slave-deployment.yaml" created
```

Issue1: How to get guestbook image

```
    spec:
      containers:
      - image: guestbook
        imagePullPolicy: ""
        name: guestbook
        ports:
        - containerPort: 3000
        resources: {}
      restartPolicy: Always
      serviceAccountName: ""
      volumes: null
```

Solution1: Use minikube registry

see https://minikube.sigs.k8s.io/docs/handbook/pushing/#4-pushing-to-an-in-cluster-using-registry-addon


minikube addons enable registry
make minikube.tag

```
make minikube.tag
docker tag guestbook:latest 192.168.99.102:5000/guestbook
```
make minikube.push
```
make minikube.push
docker push 192.168.99.102:5000/guestbook
```

We push image to minikube registry at 192.168.99.102:5000/guestbook

but inside minikube host it will be `localhost:5000/guestbook`

Update `guestbook-deployment.yaml` to have something like


Issues2: Can not access Redis Slave

Remember redis-slave in docker-compose.yaml

```
redis-slave:
  image: gcr.io/google_samples/gb-redisslave:v1
  links:
    - redis-master:redis-master
  ports:
    - 3002:6379
```    

it will generate following block in `redis-slave-service.yaml`

```
spec:
  ports:
  - name: "3002"
    port: 3002
    targetPort: 6379
  selector:
    io.kompose.service: redis-slave
```    


we need to correct port 3002 to 6379

```
spec:
  ports:
  - name: "6379"
    port: 6379
    targetPort: 6379
  selector:
    io.kompose.service: redis-slave
```    

Why???

Because in main.go, we're refering to

```
func main() {
	masterPool = simpleredis.NewConnectionPoolHost("redis-master:6379")
	defer masterPool.Close()
	slavePool = simpleredis.NewConnectionPoolHost("redis-slave:6379")
	defer slavePool.Close()

```

-----
Running docker with Kube

kubectl apply -f kubernetes

Check services

```
 kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
guestbook      ClusterIP   10.98.44.14     <none>        3000/TCP   3m19s
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP    2d
redis-master   ClusterIP   10.104.74.235   <none>        6379/TCP   3m19s
redis-slave    ClusterIP   10.99.99.20     <none>        6379/TCP   3m19s
```


Seeeing guestbook service network type is `ClusterIP`

we can test it by

minikube ssh

$ curl 10.98.44.14:3000



Change to NodePort
edit `guestbook-service.yaml`

```
spec:
  ports:
  - name: "3000"
    port: 3000
    targetPort: 3000
  selector:
    io.kompose.service: guestbook
  type: NodePort
```

kubectl get svc
```
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
guestbook      NodePort    10.98.44.14     <none>        3000:32219/TCP   9m47s

```

we can verify the app in your box

```
curl http://$(minikube ip):32219
```

Using Type LoadBalancer


edit `guestbook-service.yaml`

```
spec:
  ports:
  - name: "3000"
    port: 3000
    targetPort: 3000
  selector:
    io.kompose.service: guestbook
  type: LoadBalancer
```

kubectl get svc
```
kubectl get svc
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
guestbook      LoadBalancer   10.98.44.14     <pending>     3000:32219/TCP   12m
kubernetes     ClusterIP      10.96.0.1       <none>        443/TCP          2d
redis-master   ClusterIP      10.104.74.235   <none>        6379/TCP         12m
redis-slave    ClusterIP      10.99.99.20     <none>        6379/TCP         12m
```

we can verify the app in your box

```
minikube service guestbook 
```

Lessson Learn

Understand Kubernetes Basic Operations
Kubernetes Networking

ClusterIP vs NodePort vs LoadBalancer