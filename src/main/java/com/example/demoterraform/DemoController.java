package com.example.demoterraform;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {

    @GetMapping("/demo")
    public String getDetails(){
        return "Yes,,, your App is working";
    }
}
