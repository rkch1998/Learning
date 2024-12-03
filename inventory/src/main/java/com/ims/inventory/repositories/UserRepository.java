package com.ims.inventory.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ims.inventory.entities.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long>{

    Optional<User> findByUserName(String userName);

}
