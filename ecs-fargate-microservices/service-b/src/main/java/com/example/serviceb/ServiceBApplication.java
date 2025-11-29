package com.example.serviceb;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@SpringBootApplication
@EnableScheduling
public class ServiceBApplication {

    private static final Logger log = LoggerFactory.getLogger(ServiceBApplication.class);

    // Cloud Map DNS name for Service A
    private static final String SERVICE_A_URL = "http://service-a.local:8080/";

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @GetMapping("/")
    public String hello() {
        return "Hello from Service B";
    }

    // This will run every 5 seconds
    @Scheduled(fixedDelay = 5000)
    public void callServiceA() {
        log.info("🔄 Calling Service A at {}", SERVICE_A_URL);

        try {
            RestTemplate rt = restTemplate();
            String response = rt.getForObject(SERVICE_A_URL, String.class);

            log.info("✅ Received from Service A: {}", response);

        } catch (Exception ex) {
            log.error("❌ Failed to call Service A: {}", ex.getMessage());
        }
    }

    public static void main(String[] args) {
        SpringApplication.run(ServiceBApplication.class, args);
    }
}
