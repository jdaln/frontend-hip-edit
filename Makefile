.DEFAULT_GOAL := help

GITHUB_REPO=HIP-infrastructure/hip
APP_NAME=hip

include .env
export

#build : @ Build components locally
build.prod: b.hipapp

b.hipapp:
	cd hip && git checkout master && cd ..
	make -C hip build

#deploy.prod: @ Deploy the frontend stack in production mode
deploy.prod: build.prod d.nextcloud d.hipapp d.reddis

d.nextcloud:
	docker-compose \
		-f nextcloud-docker/docker-compose.yml \
		--env-file ./.env \
		up -d

d.hipapp:
	sudo rm -rf /mnt/nextcloud-dp/nextcloud/apps/hip
	sudo mkdir /mnt/nextcloud-dp/nextcloud/apps/hip
	sudo tar -zxvf hip/release.tar.gz -C /mnt/nextcloud-dp/nextcloud/apps/hip
	sudo chown -R www-data:root $(NC_APP_FOLDER)

d.reddis:
	docker-compose \
		-f ./docker-compose.yml \
		--env-file ./.env \
		up -d

#deploy.dev: @ Deploy the frontend stack in dev mode
deploy.dev: d.nextcloud.dev d.hipapp.dev

d.nextcloud.dev:
	docker-compose \
		-f nextcloud-docker/docker-compose.yml \
		--env-file ./.env \
		up -d

d.socialapp.dev:

d.hipapp.dev:
	sudo mkdir -p $(NC_APP_FOLDER)/hip
	sudo cp -rf ./hip/appinfo $(NC_APP_FOLDER)/hip
	sudo cp -rf ./hip/lib $(NC_APP_FOLDER)/hip
	sudo cp -f ./hip/templates/index.php $(NC_APP_FOLDER)/hip/templates/index.php
	sudo chown -R www-data:root $(NC_APP_FOLDER)/hip
	docker-compose \
		-f docker-compose-dev.yml \
		--env-file ./.env \
		up -d

d.bidsimporter.dev:

d.gateway.dev:


#deploy.dev.stop: @ Stop the frontend stack in dev mode
deploy.dev.stop: 
	docker-compose \
		-f nextcloud-docker/docker-compose.yml \
		--env-file ./.env \
		stop
	docker-compose \
    -f docker-compose-dev.yml \
    stop

#help:	@ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
