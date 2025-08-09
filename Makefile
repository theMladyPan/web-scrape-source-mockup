export SERVICE_ACCOUNT=399518081439-compute@developer.gserviceaccount.com
export REPOSITORY=europe-west1-docker.pkg.dev/webygroup-ai/general
export PROJECT_NAME=web-scrape-source-mockup


# formerly
# export CHATBOT_API_KEY=prod-api-key-123
requirements.txt:
	uv pip freeze > requirements.txt

gcp-build: requirements.txt
	@echo "Deploying to Google Cloud Run..."
	@echo "\033[1;32mUsing project name: $(PROJECT_NAME) \033[0m"
	@echo "\033[1;32mUsing service account: $(SERVICE_ACCOUNT) \033[0m"
	@echo "\033[1;32mUsing repository: $(REPOSITORY) \033[0m"


	@echo "** Building Docker image for GCP... **"
	docker build --pull --rm -f 'Dockerfile' -t '$(REPOSITORY)/$(PROJECT_NAME):latest' '.'

	@echo "cleaning up requirements.txt"
	@rm -f requirements.txt

	@echo "** Pushing Docker image to GCP... **"
	docker push $(REPOSITORY)/$(PROJECT_NAME):latest

deploy: gcp-build
	@echo "** (re)Create cloud RUN service... **"
	gcloud beta run deploy $(PROJECT_NAME) \
		--image=$(REPOSITORY)/$(PROJECT_NAME):latest \
		--allow-unauthenticated \
		--port=8080 \
		--service-account=$(SERVICE_ACCOUNT) \
		--concurrency=1 \
		--memory=1Gi \
		--set-env-vars=PROJECT=$(PROJECT_NAME) \
		--set-env-vars=DEBUG=false \
		--set-env-vars=ENVIRONMENT=prod \
		--network=main \
		--subnet=main-sub \
		--vpc-egress=all-traffic \
		--session-affinity \
		--no-cpu-throttling \
		--region=europe-west1 \
		--project=webygroup-ai

	@echo "\033[1;32m** Deployment complete! ** \033[0m"