JAVA_HOME=/usr/pkg/java/oracle-8
CATALINA_HOME=/opt/tomcat10
CATALINA_PID="$CATALINA_BASE/tomcat.pid"
CATALINA_OPTS="-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.PollSelectorProvider"
export JAVA_HOME CATALINA_HOME CATALINA_OPTS