package com.db.execution.function;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Component;
import com.db.execution.util.DateTimeFormat;

@Component
public class TransformExecution {

    public String transformSqlQuery(String sql, Map<String, String> arguments) {

		for (Map.Entry<String, String> entry : arguments.entrySet()) {
			String argumentName = entry.getKey();
			String dataType = entry.getValue();
	
			// Regex to match the argument with or without array/JSON structure
			String regex = String.format("%s=>(\\{.*?\\}|\\[.*?\\]|'''(.*?)'''|'[^']*'|[^,\\)]+)", argumentName);
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(sql);
	
			while (matcher.find()) {
				String matchedValue = matcher.group(1);
				
				String replacement;
	
				// Check if the matched value is an array or JSON structure (starts with '[')
				if ((matchedValue.startsWith("[{") && matchedValue.endsWith("}]"))) {

					// Wrap the matched value with ARRAY and apply the data type casting
					String dtype = dataType.replaceAll("\\[\\]", "");
					
					replacement = String.format("%s=>ARRAY(SELECT json_populate_recordset(null ::%s,'%s'))", argumentName, dtype, matchedValue);

				} else if((matchedValue.startsWith("{") && matchedValue.endsWith("}"))){

					replacement = String.format("%s=>(SELECT json_populate_recordset(null ::%s,'[%s]'))", argumentName, dataType, matchedValue);
				} 
				else if (matchedValue.startsWith("[") && matchedValue.endsWith("]")) {

					// Wrap the matched value with ARRAY and apply the data type casting
					replacement = String.format("%s=>ARRAY%s::%s", argumentName, matchedValue, dataType);

				} else if (matchedValue.startsWith("'") && matchedValue.endsWith("'")) {
                    
                    //checking for date possibility
                    if(matchedValue.contains("-")){
                        //Replacing date
                        replacement = replaceDate(argumentName, matchedValue);

                    }else{
                        // Remove the surrounding single quotes for proper SQL syntax
                        matchedValue = matchedValue.substring(1, matchedValue.length() - 1);
                        // Apply the data type casting as VARCHAR
                        replacement = String.format("%s=>'%s'::VARCHAR", argumentName, matchedValue);
                    }
				} else {
					// Apply the data type casting without ARRAY
					replacement = String.format("%s=>%s::%s", argumentName, matchedValue, dataType);
				}
	
				// Replace the original argument with the transformed value
				sql = sql.replace(matcher.group(0), replacement);
			}
		}
		return sql;
	}

    private String replaceDate(String argumentName, String matchedValue) {
        String replacement;
        //converting date format from 'dd-MM-yyyy' to 'yyyy-MM-dd'
        String formattedDate = DateTimeFormat.dateTimeFormat(matchedValue);

        //If date convertion is successful, apply TIMESTAMP casting
        if(formattedDate != null){
            // Apply the data type casting as TIMESTAMP WITHOUT TIME ZONE
            replacement = String.format("%s=>'%s'::TIMESTAMP WITHOUT TIME ZONE", argumentName, formattedDate);
        } else {
            // If date conversion fails, handle it as a normal VARCHAR type
            matchedValue = matchedValue.substring(1, matchedValue.length() - 1);
            replacement = String.format("%s=>'%s'::VARCHAR", argumentName, matchedValue);
        }
        return replacement;
    }
	
}   

