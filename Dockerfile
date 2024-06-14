#
# DSpace image
#
ARG JDK_VERSION=17

FROM openjdk:${JDK_VERSION}-bullseye AS build
LABEL maintainer="Mohammad Salem <mohammad.salem@codeobia.com>"

ENV CONFIG_DSPACE_ACTIVE_THEME=MELSpace

# Environment variables
ENV DSPACE_HOME=/dspace
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
ENV MAVEN_FLAGS="-Denforcer.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true -Dxml.skip=true -Pdspace-rest"

ENV MAVEN_VERSION=3.9.7

# Use ant from a tarball so we don't have to install it from apt with Java 11
ENV ANT_VERSION=1.10.13
ENV ANT_HOME=/tmp/ant-$ANT_VERSION
ENV PATH=$ANT_HOME/bin:$PATH
# Need wget to install ant
RUN wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xvf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && mv apache-maven-${MAVEN_VERSION} /opt/ \
    && mkdir $ANT_HOME \
    && wget -qO- "https://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz" | tar -zx --strip-components=1 -C $ANT_HOME

RUN /opt/apache-maven-${MAVEN_VERSION}/bin/mvn -version
WORKDIR /tmp

# Add a non-root user to perform the Maven build
RUN useradd -r -s /bin/bash -m -d "$DSPACE_HOME" dspace

# copy source to $WORKDIR/dspace
COPY --chown=dspace:dspace . dspace/

# Change to dspace user for build and install
USER dspace

# Copy customized DSpace local.cfg
COPY --chown=dspace:dspace custom_configuration/config/local.cfg dspace/config/

# Copy customized default license
COPY --chown=dspace:dspace custom_configuration/themes/$CONFIG_DSPACE_ACTIVE_THEME/default.license dspace/config/

WORKDIR /tmp

# Change back to dspace user to build the code
USER dspace

# Build DSpace
RUN cd dspace && /opt/apache-maven-${MAVEN_VERSION}/bin/mvn --no-transfer-progress package ${MAVEN_FLAGS}

# Install compiled applications to $DSPACE_HOME
RUN cd dspace/dspace/target/dspace-installer \
    && ant init_installation init_configs install_code copy_webapps

# Copy handle server
RUN if [ -d /tmp/dspace/custom_configuration/themes/$CONFIG_DSPACE_ACTIVE_THEME/handle-server ]; \
        then cp -r /tmp/dspace/custom_configuration/themes/$CONFIG_DSPACE_ACTIVE_THEME/handle-server $DSPACE_HOME/; \
        else echo "No Handle server files found"; \
    fi

# Copy custom discovery settings
COPY --chown=dspace:dspace custom_configuration/themes/$CONFIG_DSPACE_ACTIVE_THEME/discovery.xml $DSPACE_HOME/config/spring/api/discovery.xml

# Change back to root user for cleanup
USER root

# Cleanup build deps
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove \
    && rm -rf "$DSPACE_HOME/.m2" /tmp/*

FROM tomcat:9-jdk${JDK_VERSION}
# Give java extra memory (2GB)
ENV JAVA_OPTS=-Xmx2024m
# Set some variables for the Tomcat container. Some were already set above in
# the build container, but they don't get propagated in multi-stage builds.
ENV DSPACE_HOME=/dspace \
    CATALINA_OPTS="-Xmx2024m -Xms2024m -Dfile.encoding=UTF-8"
# Make sure to set PATH *after* setting $VIRTUAL_ENV or else it won't exist yet!
ENV PATH="$CATALINA_HOME/bin":"$DSPACE_HOME"/bin:$PATH

# Add DSpace user to this container *without* creating the home directory
# because we will copy it from the build container
RUN useradd -r -s /bin/bash -M -d "$DSPACE_HOME" dspace

# Remove default Tomcat webapps
RUN rm -rf "$CATALINA_HOME/webapps"

# Copy the $DSPACE_HOME (/dspace) directory from the build container to
# the Tomcat runtime container.
COPY --chown=dspace:dspace --from=build "$DSPACE_HOME" "$DSPACE_HOME"

# Add webapps Tomcat's webapps directory.
RUN mv -f "$DSPACE_HOME/webapps" "$CATALINA_HOME/" \
    && sed -i s/CONFIDENTIAL/NONE/ "$CATALINA_HOME"/webapps/rest/WEB-INF/web.xml

# Tweak default Tomcat server configuration
COPY custom_configuration/config/server.xml "$CATALINA_HOME"/conf/server.xml

# Install root filesystem
COPY custom_configuration/rootfs /

# Make sure the crontab uses the correct DSpace directory
RUN sed -i "s#DSPACE=/dspace#DSPACE=$DSPACE_HOME#g" /etc/cron.d/dspace-maintenance-tasks \
    && rm -rf /tmp/* \
    && chmod 644 /etc/cron.d/dspace-maintenance-tasks

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y \
    postgresql-client \
    imagemagick \
    ghostscript \
    cron \
    less \
    vim \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove

WORKDIR "$DSPACE_HOME"

COPY custom_configuration/GeoLite2-City/GeoLite2-City.mmdb "$DSPACE_HOME"/config/

RUN apt-get update \
    && apt-get install -y \
    schedtool \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove
# Change to dspace user for for adding cron jobs
USER dspace
RUN (crontab -l 2>/dev/null; echo '# Compress DSpace logs (checker.log, cocoon.log, handle-plugin.log and solr.log) older than yesterday') | crontab - \
    && (crontab -l 2>/dev/null; echo '20 0 * * * find '$DSPACE_HOME'/log -regextype posix-extended -iregex ".*\.log.*" ! -iregex ".*dspace\.log.*" ! -iregex ".*\.xz" ! -newermt "Yesterday" -exec schedtool -B -e ionice -c2 -n7 xz {} \; >> '$DSPACE_HOME'/log/cron_tab_logs.log 2>&1') | crontab - \
    && (crontab -l 2>/dev/null; echo '# Compress DSpace logs (dspace.log) older than 1 week') | crontab - \
    && (crontab -l 2>/dev/null; echo '25 0 * * * find '$DSPACE_HOME'/log -regextype posix-extended -iregex ".*dspace\.log.*" ! -iregex ".*\.xz" ! -newermt "1 week ago" -exec schedtool -B -e ionice -c2 -n7 xz {} \; >> '$DSPACE_HOME'/log/cron_tab_logs.log 2>&1') | crontab - \
    && (crontab -l 2>/dev/null; echo '# Compress Tomcat logs (catalina, host-manager, localhost and manager) older older than yesterday') | crontab - \
    && (crontab -l 2>/dev/null; echo '30 0 * * * find '$CATALINA_HOME'/logs -regextype posix-extended -iregex ".*\.log.*" ! -iregex ".*\.xz" ! -newermt "Yesterday" -exec schedtool -B -e ionice -c2 -n7 xz {} \; >> '$DSPACE_HOME'/log/cron_tab_logs.log 2>&1') | crontab - \
    && (crontab -l 2>/dev/null; echo '# Compress Tomcat logs (localhost_access_log) older than 1 week') | crontab - \
    && (crontab -l 2>/dev/null; echo '35 0 * * * find '$CATALINA_HOME'/logs -regextype posix-extended -iregex ".*\.txt" ! -iregex ".*\.xz" ! -newermt "1 week ago" -exec schedtool -B -e ionice -c2 -n7 xz {} \; >> '$DSPACE_HOME'/log/cron_tab_logs.log 2>&1') | crontab -
USER root

RUN chown -R dspace:dspace "$DSPACE_HOME" "$CATALINA_HOME"/logs "$CATALINA_HOME"/conf

ENV DSPACE_VERSION=7_x
# Build info
RUN echo "Debian GNU/Linux `cat /etc/debian_version` image. (`uname -rsv`)" >> /root/.built \
    && echo "- with `java -version 2>&1 | awk 'NR == 2'`" >> /root/.built \
    && echo "- with DSpace $DSPACE_VERSION on Tomcat $TOMCAT_VERSION"  >> /root/.built \
    && echo "\nNote: if you need to run commands interacting with DSpace you should enter the" >> /root/.built \
    && echo "container as the dspace user, ie: docker exec -it -u dspace dspace /bin/bash" >> /root/.built

# Ensure that the database is ready BEFORE starting tomcat
# 1. While a TCP connection to dspacedb port 5432 is not available, continue to sleep
# 2. Then, run database migration to init database tables
# 3. Finally, run `start-dspace` script as root, then drop to dspace user
CMD ["/bin/bash", "-c", "start-dspace"]
