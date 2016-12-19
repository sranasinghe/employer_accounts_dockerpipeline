APP_NAME = employer-accounts
CONTAINER_BASE_NAME = $(shell basename ${PWD} | sed s'/[_-]//g')

# This is what the deployment does
# set -e
### no push
# make qualify

### this pushes
# stack stage $(make task_defs)

# Deletes the app images
#
nuke: clean
	docker rmi -f registry.wellmatchhealth.com/${APP_NAME}
	docker rmi -f registry.wellmatchhealth.com/${APP_NAME}_dev

# Build and publish the images. 
# This is separate from make images so that we only do this after testing
publish:
	docker tag registry.wellmatchhealth.com/${APP_NAME} registry.wellmatchhealth.com/${APP_NAME}:latest
	docker push registry.wellmatchhealth.com/${APP_NAME}:latest
	docker push registry.wellmatchhealth.com/${APP_NAME}_dev

# removes all containers and builds images.
#
images: clean
	docker build -t registry.wellmatchhealth.com/${APP_NAME} .
	docker build -t registry.wellmatchhealth.com/${APP_NAME}_dev -f Dockerfile.development .

# integration point with deployment infrastructure.  currently lists
# static files.  in the future *maybe* build these files dynamically
# and list the results.
task_defs:
	@ls $(PWD)/ecs/*

# Only run this as part of CI since it publishes built images
qualify: images test publish
	
databases: confirm-available
	docker-compose run development bundle exec rake db:create db:migrate
	docker-compose run test bundle exec rake db:create

mock_server: stop
	docker-compose up -d --no-recreate mock_development
	docker attach ${CONTAINER_BASE_NAME}_mock_development_1
	docker-compose logs mock_development

mock_debug: stop
	docker-compose run --service-ports mock_development bundle exec rackup -o0.0.0.0 -p8000

# stops containers and removes them.
#
clean:
	docker-compose kill
	docker-compose rm --force -v

# starts all services and attaches to containers.
# runs containers in the background.
#
start: stop server logs
	docker attach ${CONTAINER_BASE_NAME}_development_1

# stops all running containers.
stop:
	docker-compose stop

# stops and restarts the API service
#
restart:
	docker-compose restart development

server:
	docker-compose up -d development

# shells into the service in interactive mode.
server-shell:
	docker-compose run development /bin/bash

# outputs logs from services.
#
logs:
	docker-compose logs development

test: test-unit test-quality

confirm-available:
	docker-compose up -d postgres
	./bin/confirm_available postgres_service

test-unit: confirm-available
	docker-compose run test bundle exec rake db:drop db:create db:migrate
	docker-compose run test bundle exec rake test

test-quality:
	docker-compose run --rm development rubocop --format progress --format json --display-cop-names --out tmp/rubocop.json

coverage_start:
	docker-compose up -d coverage

coverage_stop:
	docker-compose stop coverage

debug: stop
	docker-compose run --service-ports development bundle exec rackup -o0.0.0.0 -p8000

psql:
	docker-compose run --entrypoint /bin/bash postgres /srv/app/exe/launch_psql_console 

rails-console:
	docker-compose run development rails c

#
# Container
# 

run-unit:
	bundle exec rake test

.PHONY: \
  images \
  clean \
  test \
  test-quality \
  server \
  logs \
  stop \
  start \
  restart \
  server-shell \
  psql \
  rails-console \
  coverage_start \
  coverage_stop \
  mock_server \
  mock_debug
