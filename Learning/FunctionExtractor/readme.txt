#for executing the application
--  java -jar build/libs/function-0.0.1-SNAPSHOT.jar --spring.profiles.active=pg functions.txt tenant

#for changing the database 
--  spring.profiles.active=sql
--  spring.profiles.active=pg

# provide the list of function name into functions.txt file

# change the database according to you where your function is located
tenant, master, appdata, log, admin