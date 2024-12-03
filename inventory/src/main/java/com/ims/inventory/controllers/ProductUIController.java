package com.ims.inventory.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ProductUIController {
    @GetMapping("/products-ui")
    public String productsPage() {
        return "products";
    }

    @GetMapping("/products-ui/new")
    public String newProductPage() {
        return "products";
    }

    @GetMapping("/products-ui/edit/{id}")
    public String editProductPage() {
        return "products";
    }
}
