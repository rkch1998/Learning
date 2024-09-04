#Requerment
	download java version 21 
	https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe
	and add the bin location to environment variable.
	
#for executing this application 
	java -jar getFunction.jar --spring.profiles.active=pg tenant
	
#if you want to get the function from sql server local then use this 
	--spring.profiles.active=sql

#make changes in compare.bat file as per your project list or 
#connection you have added into db_config.json file