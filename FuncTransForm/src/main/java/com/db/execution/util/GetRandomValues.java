package com.db.execution.util;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.Random;

public class GetRandomValues {

    private static final Random random = new Random();

    public static Object getRandomValue(String datatype){
        switch (datatype.toLowerCase()) {
            case "integer[]":
            case "smallint[]":
            case "bigint[]":
            return getRandomIntegerArray(5);  // Random int array
            case "integer":
            case "smallint":
            case "bigint":
                return random.nextInt(100);  // Random int
            case "character varying[]":
                return getRandomStringArray(5);  // Random varchar array
            case "character varying":
                return getRandomString(5);  // Random string of length 10
            case "boolean":
                return random.nextBoolean();  // Random boolean
            case "numeric":
            case "decimal":
                return String.format("%.2f", random.nextDouble() * 100);  // Random numeric/decimal
            case "timestamp without time zone":
            case "date":
                return getRandomTimestamp();  // Random timestamp
            default:
                return "null";
        }
    }

    @SuppressWarnings("unused")
    private static LocalDate getRandomDate(){
        int year = random.nextInt(13) + 2010;
        int dayOfYear = random.nextInt(365) + 1;
        return LocalDate.ofYearDay(year, dayOfYear);
    }

    private static String getRandomString(int length){
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        StringBuilder sb = new StringBuilder();
        sb.append("'");
        for(int i = 0; i < length; i++){
            sb.append(characters.charAt(random.nextInt(characters.length())));
        }
        sb.append("'");
        // System.out.println(sb.toString());
        return sb.toString();
    }

    private static String getRandomTimestamp() {
        long millis = System.currentTimeMillis() - random.nextInt(1000000000);
        Timestamp date =  new Timestamp(millis);
        return "'" + date.toString() + "'";
    }

    private static String getRandomIntegerArray(int length){
        StringBuilder array = new StringBuilder("ARRAY[");
        for(int i = 0; i < length; i++){
            array.append(random.nextInt(100));
            if(i < length - 1){
                array.append(", ");
            }
        }
        array.append("]");
        return array.toString();
    }

    public static String getRandomIntStringArray(int length){
        StringBuilder array = new StringBuilder("'");
        for(int i = 0; i < length; i++){
            array.append(random.nextInt(100));
            if(i < length - 1){
                array.append(", ");
            }
        }
        array.append("'");
        return array.toString();
    }

    public static String getRandomQuotesStringArray(int length){
        StringBuilder array = new StringBuilder("'");
        for(int i = 0; i < length; i++){
            array.append("'").append(getRandomString(length)).append("'");
            if(i < length - 1){
                array.append(", ");
            }
        } 
        array.append("'");
        return array.toString();
    }

    private static String getRandomStringArray(int length){
        StringBuilder array = new StringBuilder("ARRAY[");
        for(int i = 0; i < length; i++){
            array.append(getRandomString(length));
            if(i < length - 1){
                array.append(", ");
            }
        }
        array.append("]");
        return array.toString();
    }    

}
