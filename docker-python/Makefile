run:
	NAME=Tom PORT=8888 REDIS=10.152.183.175 python3 app.py

test:
	curl localhost:8888

build:
	docker build --tag=tomtor/test-k8s:hello-0.1 .

deploy:
	kubectl create deployment hello-redis --image=tomtor/test-k8s:hello-0.1
	kubectl expose deployment hello-redis --port 80

redeploy:
	kubectl set image deployment/hello-redis hello-redis=tomtor/test-k8s:hello-0.x

