cd ..
call mvn clean package -am -Dmaven.test.skip=true -Pproduct -U
pause