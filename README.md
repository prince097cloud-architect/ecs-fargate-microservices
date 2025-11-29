✅ THE COMPLETE CHECKLIST FOR YOUR ARCHITECTURE

This is a production-ready checklist you can use for validation, documentation, Medium post, or audits.

I’m breaking it into:

1. VPC & Networking
2. ALB (Private)
3. NLB (Public → Private ALB)
4. ECS Cluster
5. Cloud Map (Service Discovery)
6. ECS → ECS Internal Communication Checklist
7. Java App Logical Validation
8. Final Integrated Architecture Checklist

This will be extremely detailed and exactly what you need.

🟦 1. VPC & Networking Checklist

✔ VPC created
✔ Private subnets for ECS tasks (no internet access)
✔ Private subnets for internal ALB
✔ Public subnets for NLB
✔ enable_dns_support = true
✔ enable_dns_hostnames = true
✔ Route tables correctly attached
✔ Correct NAT gateways (if tasks need outbound)
✔ NACLs not blocking port 8080 between private subnets
✔ Security groups NOT overly restrictive
✔ VPC CIDR allows inter-subnet communication (all same VPC → yes)

🟩 2. ECS Cluster Checklist

✔ ECS Cluster created
✔ Tasks using awsvpc network mode
✔ Task ENI gets VPC IP in private subnets
✔ Service A & B deployed in same VPC
✔ Auto-assign IP enabled
✔ Task Definition exposes port 8080
✔ Container listens on 0.0.0.0:8080
✔ Health checks pass

🟧 3. Service A (ECS) Checklist

✔ Running in private subnet
✔ Uses security group: ecs_tasks_sg
✔ Has Cloud Map service registry
✔ Registered into service-a.local
✔ Returns HTTP 200 on / and /actuator/health
✔ Logs visible in CloudWatch

🟥 4. Service B (ECS) Checklist

✔ Running in private subnet
✔ Uses same SG as service A (or allowed SG)
✔ Has Cloud Map service registry
✔ Registered into service-b.local
✔ Has Java scheduler calling Service A
✔ Successful internal call logs visible

🟨 5. Cloud Map (Service Discovery) Checklist

✔ Private DNS namespace created (local)
✔ Service A → service-a.local
✔ Service B → service-b.local
✔ health_check_custom_config used
✔ No health_check_config (not allowed for private namespace)
✔ ECS service has:

service_registries {
  registry_arn = aws_service_discovery_service.svc_a.arn
  port = 8080
}


✔ Each ECS task instance is registered in Cloud Map
✔ nslookup service-a.local resolves to ECS task ENIs
✔ nslookup service-b.local resolves to ECS task ENIs
✔ TTL set appropriately (10 seconds)

🟦 6. Internal Communication (A ↔ B) Security Checklist

This is the critical part that caused the issue earlier.

✔ Both services MUST be in same VPC
✔ Both services MUST be in same SG or cross-allow SGs
✔ Inbound SG rule (mandatory):
ingress: 8080 from <ecs_tasks_sg>


If same SG:

self = true

✔ Outbound SG must allow ANY to VPC CIDR (default)
✔ NACL must not block traffic
✔ No ALB required for service-to-service (direct VPC traffic)
🟩 7. Private ALB Checklist (Internal ALB)

✔ ALB deployed in private subnets
✔ ALB SG allows inbound from NLB SG
✔ Target group contains ECS tasks
✔ Health check path /actuator/health
✔ Listener: HTTP/HTTPS → TG
✔ ALB does not face public internet
✔ ALB DNS only accessible within VPC or VPC-peered networks

🟧 8. NLB (Public) → ALB (Internal) Checklist

✔ NLB deployed in public subnets
✔ NLB listener forwards traffic to ALB target group
✔ NLB SG allows inbound from anywhere (if public)
✔ ALB SG allows inbound from NLB SG
✔ TLS certificate on NLB
✔ NLB returns traffic to ALB → ECS tasks
✔ This provides external access safely without exposing ECS tasks directly

🟩 9. Java App Integration Checklist
Service A

✔ Returns simple string
✔ No outbound calls
✔ Lightweight

Service B

✔ Uses RestTemplate
✔ Scheduler enabled
✔ Calls Service A every 5 seconds
✔ Logs:

🔄 Calling Service A at http://service-a.local:8080/
✅ Received from Service A: Hello from Service A


✔ Handles failures
✔ Long-running
✔ Works inside ECS exec tests

🟥 10. FINAL “EVERYTHING MUST PASS” CHECKLIST

This is your Master Checklist to ensure the entire architecture is functioning:

VPC

✔ DNS support + hostname enabled
✔ Private & public subnets correct
✔ Routing correct

ECS

✔ Tasks run in private subnet
✔ awsvpc mode
✔ Ports exposed
✔ Health checks pass

Security Groups

✔ ALB → ECS allowed
✔ NLB → ALB allowed
✔ ECS ↔ ECS allowed using self-reference

Cloud Map

✔ Private namespace
✔ Service registry attached
✔ nslookup service-a.local resolves
✔ nslookup service-b.local resolves
✔ TTL working
✔ ECS tasks registered dynamically

Connectivity

✔ curl service-a.local from service-B works
✔ curl service-b.local from service-A works
✔ Application logs show successful calls

Java Services

✔ Service B continuously calling Service A
✔ Logs flowing
✔ Error handling correct
✔ High-visibility logs confirm communication

External Access

✔ NLB → ALB → ECS works
✔ TLS on NLB
✔ No public exposure of ECS tasks

CLIENT → Public NLB (Public Subnets)
              │
              ▼
      Internal ALB (Private Subnets)
              │
      ┌───────┼────────┐
      │        │        │
 Service A   Service B   (More Services)
 (ECS)       (ECS)
 
Cloud Map Private DNS Namespace: "local"
 ├── service-a.local → ENI IPs of Service A tasks
 └── service-b.local → ENI IPs of Service B tasks

Route 53 Private Hosted Zone (Managed by Cloud Map)
