package com.db.execution.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class DateTimeFormat {

    public static String dateTimeFormat(String input){
        //Removing single quotes from the input string
        input = input.replace("'", "");
        
        try{
            //Expected input format for datetime
            DateTimeFormatter inputFormat = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss.SSSSSS");
            //Parseing input string into LocalDatTime as per input format 
            LocalDateTime date = LocalDateTime.parse(input, inputFormat);
            //Desired output format
            DateTimeFormatter outputFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSS");
            // Format the parsed date to the output format
            String formattedDate = date.format(outputFormat);
            //Return the formatted date 
            return formattedDate;
        } catch(DateTimeParseException e){
            // System.out.println("Invalid date format: " + input);
            return null;
        }
    }
    
}
