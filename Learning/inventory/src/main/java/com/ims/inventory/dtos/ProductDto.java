package com.ims.inventory.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor 
public class ProductDto {
    private Long id;
    private Long inventoryId;
    private String productName;
    private int quantity;
    private Double price;
    private String description;
}
