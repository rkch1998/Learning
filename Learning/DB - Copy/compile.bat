@echo off
set SRC_DIR=D:/Learn/GitHub/Ravi/Learning/Learning/DB/src
set BIN_DIR=D:/Learn/GitHub/Ravi/Learning/Learning/DB/bin

mkdir %BIN_DIR%
javac -d %BIN_DIR% %SRC_DIR%/com/connect/DB/*.java %SRC_DIR%/com/connect/DB/data/*.java %SRC_DIR%/com/connect/DB/entities/*.java %SRC_DIR%/com/connect/DB/service/*.java %SRC_DIR%/com/connect/DB/util/*.java