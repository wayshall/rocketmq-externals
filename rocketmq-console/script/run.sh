logdir="./logs"
gclogdir="./gclogs"
appenv="#{env}"
applogdir="$logdir/#{project.artifactId}"
jarname="#{project.artifactId}-#{project.version}.jar"
springProfiles="$appenv"


instName="inst1"

TEMP=`getopt -o d --long debug -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi
# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -d|--debug)
            isDebug="1"
            echo "debug enabled..."
            shift 
            ;;
        -i|--inst)
            instName="$2"
            shift 
            ;;
        *)
            shift
            break
            ;;
    esac
done

debug "mkdir -p $applogdir"
mkdir -p $applogdir

debug "mkdir -p $gclogdir"
mkdir -p $gclogdir

function debug(){
    if [ $isDebug = '1' ] ; then
        echo "[debug] $1"
    fi
}

java_opts="-server"
java_opts="$java_opts -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$gclogdir -XX:+PrintGCDetails -verbose:gc -XX:+PrintGCDateStamps -XX:+PrintCommandLineFlags"
java_opts="$java_opts -Djava.security.egd=file:/dev/./urandom"
java_opts="$java_opts -Xloggc:$gclogdir/#{project.artifactId}.log  -Dapp.log.dir=$applogdir"
java_opts="$java_opts -Dapp.env=$appenv"
java_opts="$java_opts -DmailLogOnError=true"
java_opts="$java_opts -cp \".:./*\""

spring_opts="--spring.profiles.active=$springProfiles,$instName"
spring_opts="$spring_opts --spring.config.location=file:./"
spring_opts="$spring_opts --logging.config=file:./logback.xml"

debug "java $java_opts -jar ./$jarname $spring_opts"
#java $java_opts -jar ./$jarname $spring_opts
nohup java $java_opts -jar ./$jarname $spring_opts 1>/dev/null  2>&1 &
debug "tail -500f $applogdir/$(date +%Y-%m-%d).log"
tail -500f $applogdir/$(date +%Y-%m-%d).log

