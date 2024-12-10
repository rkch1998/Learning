package com.ims.inventory.repositories;

import com.ims.inventory.entities.Inventory;

import org.springframework.stereotype.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;


@Repository
public interface InventoryRepository  extends JpaRepository<Inventory, Long> {
    // Optional<Inventory> findByUserId(Long id);

    Optional<Inventory> findById(Long id);
}
