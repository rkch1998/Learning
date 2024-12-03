package com.ims.inventory.mappers;

import org.springframework.stereotype.Component;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;
import com.ims.inventory.entities.Product;

@Component
public class InvetoryMapperImpl implements InventoryMapper{

    @Override
    public InventoryDto toDto(Inventory inventory) {
        if(inventory == null){
            return null;
        }

        InventoryDto inventoryDto = new InventoryDto();

        if(inventory.getProduct() != null){
            inventoryDto.setProductId(inventory.getProduct().getId());
        }

        inventoryDto.setId(inventory.getId());
        inventoryDto.setStockQuantity(inventory.getStockQuantity());
        inventoryDto.setLocation(inventory.getLocation());

        return inventoryDto;
    }

    @Override
    public Inventory toEntity(InventoryDto inventoryDto) {
        if(inventoryDto == null){
            return null;
        }

        Inventory inventory = new Inventory();
        Product product = new Product();
        product.setId(inventoryDto.getProductId());
        inventory.setProduct(product);
        inventory.setId(inventoryDto.getId());
        inventory.setStockQuantity(inventoryDto.getStockQuantity());
        inventory.setLocation(inventoryDto.getLocation());

        return inventory;
    }

}
