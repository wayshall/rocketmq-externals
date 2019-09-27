@echo off
setlocal
set gclogsdir="./gclogs"
mkdir %gclogsdir%
set "jarname=#{artifactId}-#{version}.jar"
set "boot_opts=--spring.profiles.active=#{env}"
set "boot_opts=%boot_opts% --spring.config.location=file:./"
set "boot_opts=%boot_opts% --logging.config=./logback.xml"
echo %boot_opts%
rem 设置日志目录
set "java_opts=-Dapp.log.dir=./logs"
set "java_opts=%java_opts% -Xloggc:%gclogsdir%/#{project.artifactId}.log"
call java %java_opts% -jar %jarname% %boot_opts% 
pause