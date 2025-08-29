package com.ecommerce.msa3.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/msa3")
public class Msa3Controller {

    @GetMapping("/")
    public String getServiceName() {
        return "MSA3";
    }
    
    @GetMapping("/actuator/health")
    public String health() {
        return "UP";
    }
}
