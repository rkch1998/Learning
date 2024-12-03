package com.ims.inventory.repositories;

import com.ims.inventory.entities.Inventory;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.JpaRepository;


@Repository
public interface InventoryRepository  extends JpaRepository<Inventory, Long> {

}
