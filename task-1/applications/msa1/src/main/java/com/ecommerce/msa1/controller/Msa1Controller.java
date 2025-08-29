package com.ecommerce.msa1.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/msa1")
public class Msa1Controller {

    @GetMapping("/")
    public String getServiceName() {
        return "MSA1";
    }
    
    @GetMapping("/actuator/health")
    public String health() {
        return "UP";
    }
}
