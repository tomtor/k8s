VERSION=0.18

run:
	NAME=Tom PORT=8888 REDIS=10.152.183.113 PGPORT=30258 python3 -u app.py

test:
	curl localhost:8888

build:
	docker build --tag=tomtor/test-k8s:hello-$(VERSION) .

push:
	docker push tomtor/test-k8s:hello-$(VERSION)

deploy:
	kubectl apply -f pythonapp-deploy.yaml
