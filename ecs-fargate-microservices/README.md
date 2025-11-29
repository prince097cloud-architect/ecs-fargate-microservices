# ecs-fargate-microservices
Serverless container orchestration using ECS Fargate.

## Project Structure
```
ecs-fargate-microservices
├── service-a
│   ├── Dockerfile
│   └── start.sh
├── service-b
│   ├── Dockerfile
│   └── wait-for-service-a.sh
├── infra
│   ├── variables.tf
│   ├── main.tf
│   ├── networking.tf
│   ├── loadbalancer.tf
│   ├── cloudmap.tf
│   ├── ecs.tf
│   └── outputs.tf
└── README.md
```

## Description
This project demonstrates how to deploy microservices using AWS ECS Fargate, allowing for serverless container orchestration. Each service is designed to be independently deployable and scalable.

## Getting Started
1. Clone the repository.
2. Navigate to the project directory.
3. Build and run the services using Docker.
4. Deploy the infrastructure using Terraform.

## Prerequisites
- Docker
- Terraform
- AWS CLI configured with appropriate permissions

## License
This project is licensed under the MIT License.