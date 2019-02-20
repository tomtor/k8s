build:
	docker build --tag=tomtor/test-k8s:test-asp-0.2 .

deploy:
	kubectl create deployment test-asp --image=tomtor/test-k8s:test-asp-0.2

expose:
	kubectl expose deployment test-asp --port 80
