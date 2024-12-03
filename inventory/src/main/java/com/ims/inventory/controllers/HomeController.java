package com.ims.inventory.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.ui.Model;

import com.ims.inventory.services.InventoryService;
import com.ims.inventory.services.ProductService;


@Controller  
public class HomeController {

    private final ProductService productService;
    private final InventoryService inventoryService;

    public HomeController(ProductService productService, InventoryService inventoryService) {
        this.productService = productService;
        this.inventoryService = inventoryService;
    }

    @GetMapping("/home")
    public String homePage(Model model) {
        model.addAttribute("products", productService.getAllProducts());
        model.addAttribute("inventory", inventoryService.getAllInventory());
        return "home"; 
    }
}

