package com.ims.inventory.utils;

// import org.springframework.context.annotation.Configuration;
// import org.springframework.security.config.annotation.web.builders.HttpSecurity;
// import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
// import org.springframework.security.core.Authentication;
// import org.springframework.security.core.context.SecurityContextHolder;
// import org.springframework.security.web.SecurityFilterChain;
// import org.springframework.context.annotation.Bean;


// import com.ims.inventory.entities.User;
// import com.ims.inventory.services.UserService;

// @Configuration
// @EnableWebSecurity
public class SecurityUtils{

    // @Bean
    // public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    //     http
    //     .csrf(csrf -> csrf.disable()) // Disable CSRF for testing (be careful with this in production)
    //     .authorizeHttpRequests(authorize -> authorize
    //         // .requestMatchers("/api/login").permitAll() // Allow access to the login API
    //         // .requestMatchers("/api/inventory").permitAll() // Allow access to the login API
    //         // .requestMatchers("/api/products").permitAll() // Allow access to the login API
    //         .anyRequest().permitAll() // Require authentication for other requests
    //     )
    //     .formLogin(form -> form
    //         .loginPage("/login") // Specify your custom login page if necessary
    //         .permitAll());

    // return http.build();
    // }
    // public static Long getLoggedInUserId(UserService userService) {
    //     Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    //     if (authentication != null && authentication.isAuthenticated()) {
    //         Object principal = authentication.getPrincipal();
    //         System.out.println(principal.getClass());
    //         if (principal instanceof User) {
    //             User userDetails = (User) principal;
    //             return userService.findUserIdByUsername(userDetails.getUsername());
    //         }
    //     }
    //     throw new RuntimeException("Unable to retrieve logged-in user ID");
    // }
}
