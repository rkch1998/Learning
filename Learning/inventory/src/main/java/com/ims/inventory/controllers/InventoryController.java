package com.ims.inventory.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.services.InventoryService;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
    

    @Autowired
    public InventoryService inventoryService;
    
    // @Autowired
    // public InventoryController(InventoryService inventoryService){
    //     this.inventoryService = inventoryService;
    // }

    @PostMapping
    public ResponseEntity<String> createProduct(@RequestBody InventoryDto inventoryDto){
        // System.out.println("Inventory DTO from controller : "+inventoryDto);
        if (inventoryDto.getId() != null) {
            throw new IllegalArgumentException("ID should not be provided when creating a new Inventory.");
        }
        inventoryService.creatInventory(inventoryDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Inventory created successfuly!");
    }

    @GetMapping("/{id}")
    public ResponseEntity<InventoryDto> getInventoryById(@PathVariable Long id){
        System.out.println( " Id from Controller : " +id);
        return ResponseEntity.ok(inventoryService.getInventoryById(id));
    }

    // @GetMapping
    // public ResponseEntity<List<InventoryDto>> getAllInventory(Model model){
    //     Long loggedInUserId = SecurityUtils.getLoggedInUserId(userService);
    //     List<InventoryDto> inventoryDto = inventoryService.getAllInventoryForUser(loggedInUserId);
    //     return ResponseEntity.ok(inventoryDto);
    // }

    @GetMapping
    public ResponseEntity<List<InventoryDto>> getAllInventory(Model model){
        List<InventoryDto> inventoryDto = inventoryService.getAllInventory();
        return ResponseEntity.ok(inventoryDto);
    }

    @PutMapping("/{id}")
    public ResponseEntity<InventoryDto> updateInventory(@PathVariable Long id, @RequestBody InventoryDto inventoryDto){
        return ResponseEntity.ok(inventoryService.updateInventory(id, inventoryDto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteInventory(@PathVariable Long id){
        inventoryService.deleteInventory(id);
        return ResponseEntity.noContent().build();
    }

}
