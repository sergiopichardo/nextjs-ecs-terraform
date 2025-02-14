AWS_VAULT_PROFILE=sergio_sso
AWS_VAULT_EXEC=aws-vault exec $(AWS_VAULT_PROFILE)
AWS_ACCOUNT_ID=152725004650
AWS_REGION=us-east-1
APP_NAME=nextjs-ecs-terraform
CPU_ARCHITECTURES=linux/amd64
BUILDX_BUILDER_NAME=nextjs-ecs-terraform-builder

# Create docker buildx builder
create-buildx-builder:
	docker buildx create --name $(BUILDX_BUILDER_NAME) --platform $(CPU_ARCHITECTURES)

set-default-buildx-builder:
	docker buildx use $(BUILDX_BUILDER_NAME)

show-buildx-builder:
	docker buildx ls

remove-buildx-builder:
	docker buildx rm $(BUILDX_BUILDER_NAME)


# Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
get-docker-auth-token:
	$(AWS_VAULT_EXEC) -- aws ecr get-login-password \
		--region $(AWS_REGION) | \
		docker login \
		--username AWS \
		--password-stdin \
		$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

# Build the docker image 
# docker buildx build --platform $(CPU_ARCHITECTURES) --load -t $(APP_NAME) .
build-docker-image:
	docker buildx build --platform linux/amd64 --load -t $(APP_NAME) .


# Run docker image locally 
run-docker-container:
	docker run -p 3000:3000 --rm --name $(APP_NAME) $(APP_NAME)

# connect to the container
connect-to-container:
	docker exec -it $(APP_NAME) /bin/sh

# tag the docker image 
tag-docker-image:
	docker tag $(APP_NAME):latest $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP_NAME):latest

# push the docker image to AWS ECR repository
upload-image-to-ecr:
	$(AWS_VAULT_EXEC) -- docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP_NAME):latest

inspect-manifest:
	docker manifest inspect $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP_NAME):latest

# Get the latest task ID
get-latest-task-id:
	$(AWS_VAULT_EXEC) -- aws ecs list-tasks \
		--cluster "measure-team-fargate-cluster" \
		--query 'taskArns[0]' \
		--output text 

connect-to-ecs-task:
	$(AWS_VAULT_EXEC) -- aws ecs execute-command \
		--region $(AWS_REGION) \
		--cluster "measure-team-fargate-cluster" \
		--task $$($(AWS_VAULT_EXEC) -- aws ecs list-tasks \
			--cluster "measure-team-fargate-cluster" \
			--query 'taskArns[0]' \
			--output text) \
		--container "$(APP_NAME)-container" \
		--interactive \
		--command "/bin/sh"

clean-images:
	if [ "$$(docker images -q)" ]; then \
		docker image rm -f $$(docker images -aq); \
	else \
		echo "No images to remove"; \
	fi

# Delete all containers
clean-containers:
	if [ "$$(docker ps -aq)" ]; then \
		docker container rm -f $$(docker ps -aq); \
	else \
		echo "No containers to remove"; \
	fi

# Delete both containers and images
clean-all: clean-containers clean-images


ecr-deploy: get-docker-auth-token build-docker-image tag-docker-image upload-image-to-ecr
