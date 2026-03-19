NAMESPACE := checkdev
SERVICES := cd_eureka cd_auth cd_desc cd_generator cd_mock cd_site cd_notification

.PHONY: build deploy down status logs open restart secrets help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

secrets:
	@bash generate-secrets.sh

build:
	@eval $$(minikube docker-env) && \
	for svc in $(SERVICES); do \
		echo "Building $$svc..."; \
		docker build -t checkdev/$$svc:latest ./services/$$svc; \
	done
	@echo "Done. All images built."

deploy: secrets build
	kubectl apply -f k8s/
	@echo ""
	@echo "Deployed. Run 'make status' to check pods."

down:
	kubectl delete namespace $(NAMESPACE) --ignore-not-found
	@echo "Namespace $(NAMESPACE) deleted."

status:
	kubectl get pods -n $(NAMESPACE)

logs:
	kubectl logs -f -l app=$(s) -n $(NAMESPACE) --tail=100

open:
	@echo "Application is available at: http://localhost:8080"
	@echo "Press Ctrl+C to stop."
	kubectl port-forward service/cd-site-svc 8080:8080 -n $(NAMESPACE)

restart:
	kubectl rollout restart deployment -n $(NAMESPACE)
	@echo "All deployments restarting."