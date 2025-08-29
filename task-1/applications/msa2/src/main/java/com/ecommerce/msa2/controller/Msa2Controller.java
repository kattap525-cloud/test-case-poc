package com.ecommerce.msa2.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/msa2")
public class Msa2Controller {

    @GetMapping("/")
    public String getServiceName() {
        return "MSA2";
    }
    
    @GetMapping("/actuator/health")
    public String health() {
        return "UP";
    }
}
