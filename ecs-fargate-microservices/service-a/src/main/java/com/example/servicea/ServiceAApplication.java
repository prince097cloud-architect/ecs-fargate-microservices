package com.example.servicea;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@RestController
@SpringBootApplication
public class ServiceAApplication {

    @GetMapping("/")
    public String hello() {
        return "Hello from Service A";
    }

    public static void main(String[] args) {
        SpringApplication.run(ServiceAApplication.class, args);
    }
}
