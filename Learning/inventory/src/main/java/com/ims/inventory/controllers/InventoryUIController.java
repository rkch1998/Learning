package com.ims.inventory.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class InventoryUIController {
    @GetMapping("/inventory-ui")
    public String inventoryPage() {
        return "inventory";
    }

    @GetMapping("/inventory-ui/new")
    public String newInventoryPage() {
        return "inventory";
    }

    @GetMapping("/inventory-ui/edit/{id}")
    public String editInventoryPage() {
        return "inventory";
    }
}
