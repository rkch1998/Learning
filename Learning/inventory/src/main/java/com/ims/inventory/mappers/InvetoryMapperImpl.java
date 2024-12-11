package com.ims.inventory.mappers;

import org.springframework.stereotype.Component;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;

@Component
public class InvetoryMapperImpl implements InventoryMapper{

    @Override
    public InventoryDto toDto(Inventory inventory) {
        // System.out.println("Mapping Inventory to InventoryDto: " + inventory);
        if(inventory == null){
            return null;
        }

        InventoryDto inventoryDto = new InventoryDto();
        
        inventoryDto.setId(inventory.getId());
        inventoryDto.setUserId(inventory.getUserId());
        inventoryDto.setInventoryName(inventory.getInventoryName());
        inventoryDto.setLocation(inventory.getLocation());

        return inventoryDto;
    }

    @Override
    public Inventory toEntity(InventoryDto inventoryDto) {
        // System.out.println("Mapping Inventory to inventory: " + inventoryDto);
        if(inventoryDto == null){
            return null;
        }
        
        Inventory inventory = new Inventory();

        inventory.setId(inventoryDto.getId());
        inventory.setUserId(inventoryDto.getUserId());
        inventory.setInventoryName(inventoryDto.getInventoryName());
        inventory.setLocation(inventoryDto.getLocation());

        return inventory;
    }

}
