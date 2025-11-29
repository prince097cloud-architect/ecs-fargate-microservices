# ecs-fargate-microservices
Serverless container orchestration using ECS Fargate.

## Project Structure
```
ecs-fargate-microservices
    ├── README.md
    ├── bash_ecr.sh
    ├── infra
    │   ├── backend.tf
    │   ├── cloudmap.tf
    │   ├── ecr.tf
    │   ├── ecs.tf
    │   ├── loadbalancer.tf
    │   ├── logging.tf
    │   ├── main.tf
    │   ├── networking.tf
    │   ├── outputs.tf
    │   ├── terraform.tfvars
    │   ├── variables.tf
    │   └── vpc_endpoint.tf
    ├── service-a
    │   ├── Dockerfile
    │   ├── app.jar
    │   ├── pom.xml
    │   ├── src
    │   │   └── main
    │   │       └── java
    │   │           └── com
    │   │               └── example
    │   │                   └── servicea
    │   │                       └── ServiceAApplication.java
    │   ├── start.sh
    │   └── target
    │       ├── classes
    │       │   └── com
    │       │       └── example
    │       │           └── servicea
    │       │               └── ServiceAApplication.class
    │       ├── generated-sources
    │       │   └── annotations
    │       ├── maven-archiver
    │       │   └── pom.properties
    │       ├── maven-status
    │       │   └── maven-compiler-plugin
    │       │       └── compile
    │       │           └── default-compile
    │       │               ├── createdFiles.lst
    │       │               └── inputFiles.lst
    │       ├── service-a-1.0.0.jar
    │       └── service-a-1.0.0.jar.original
    └── service-b
        ├── Dockerfile
        ├── app.jar
        ├── pom.xml
        ├── src
        │   └── main
        │       └── java
        │           └── com
        │               └── example
        │                   └── serviceb
        │                       └── ServiceBApplication.java
        ├── target
        │   ├── classes
        │   │   └── com
        │   │       └── example
        │   │           └── serviceb
        │   │               └── ServiceBApplication.class
        │   ├── generated-sources
        │   │   └── annotations
        │   ├── maven-archiver
        │   │   └── pom.properties
        │   ├── maven-status
        │   │   └── maven-compiler-plugin
        │   │       └── compile
        │   │           └── default-compile
        │   │               ├── createdFiles.lst
        │   │               └── inputFiles.lst
        │   ├── service-b-1.0.0.jar
        │   └── service-b-1.0.0.jar.original
        └── wait-for-service-a.sh
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


Blogpost: https://agentic-ai-for-aws-security.hashnode.dev/designing-secure-fargate-microservices-ecs-service-discovery-with-cloud-map-alb-nlb-fully-serverless-architecture 

Repo: https://github.com/prince097cloud-architect/ecs-fargate-microservices