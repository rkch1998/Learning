package com.db.execution.function;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

@Component
public class GetName {
    
    public String getFunctionName(String str){
		Pattern pattern = Pattern.compile("\"(.*?)\"\\.\"(.*?)\"");
        Pattern pattern2 = Pattern.compile("(.*?)\\.\"(.*?)\"");
        Matcher matcher = pattern.matcher(str);
        Matcher matcher2 = pattern2.matcher(str);

        if (matcher.find()) {
            String schemaName = matcher.group(1);
            String functionName = matcher.group(2);
            return schemaName + "." + functionName;
        }else if(matcher2.find()){
            String schemaName = matcher2.group(1);
            String functionName = matcher2.group(2);
            return schemaName + "." + "\"" +functionName + "\"";
        } else {
            throw new IllegalArgumentException("Function name not found in the provided SQL string.");
        }
	}

}
