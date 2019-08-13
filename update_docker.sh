$(aws ecr get-login --no-include-email --region eu-west-1)
docker build -t ecr_example_app .
docker tag ecr_example_app:latest 468964582991.dkr.ecr.eu-west-1.amazonaws.com/ecr_example_app:latest
docker push 468964582991.dkr.ecr.eu-west-1.amazonaws.com/ecr_example_app:latest