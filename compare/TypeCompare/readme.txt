#Requerment
	download java version 21 
	https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe
	and add the bin location to environment variable.

#for executing the application
 Available Products:(p)
1: local
2: casp

Available Environments: (e)
1: sample
2: fe
3: qa

set /p INPUT=Please Enter Product Number and Environment
--  java -jar compare.jar --p=local --e=sample

# make changes in compare.bat file as per your project list or 
# connection you have added into db_config.json file

# there is a sample database is is provided for the checking 
# if it is working or not

# you just have to run the "runCreateDb.bat" and your sample data base 
# as well as sample type will be created for varifing if the compare is working or not

# you can execute the application by clicking on compare.bat file or above provided 
# execution line running in cmd from the file location