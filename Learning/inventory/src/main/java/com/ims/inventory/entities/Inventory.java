package com.ims.inventory.entities;

import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Entity
@Table(name = "inventories")
@Data
@ToString
@NoArgsConstructor
public class Inventory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "userid") // Map to the column name
    private Long userId;

    @Column(name = "inventoryname") // Map to the column name
    private String inventoryName;

    @Column(name = "location") // Map to the column name
    private String location;

    @Column(name = "stamp", insertable = false, updatable = false) // Optional: to manage timestamp
    private Timestamp stamp;

    public Inventory(Long id, Long userId, String inventoryName, String location) {
        this.id = id;
        this.userId = userId;
        this.inventoryName = inventoryName;
        this.location = location;
    }
}
