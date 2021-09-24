VERSION=0.32

pull:
	cd archi_test; git pull

run:
	NAME=Tom PORT=8888 REDIS=10.152.183.113 PGHOST=localhost PGPORT=30779 python3 -u app.py

test:
	curl localhost:8888

build: pull
	docker build --tag=tomtor/test-k8s:hello-$(VERSION) .

push:
	docker push tomtor/test-k8s:hello-$(VERSION)

deploy:
	kubectl apply -f pythonapp-deploy.yaml
