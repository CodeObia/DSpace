# This image will be published as dspace/dspace
# See https://github.com/DSpace/DSpace/tree/main/dspace/src/main/docker for usage details
#
# - note: default tag for branch: dspace/dspace: dspace/dspace:dspace-7_x

# This Dockerfile uses JDK11 by default, but has also been tested with JDK17.
# To build with JDK17, use "--build-arg JDK_VERSION=17"
ARG JDK_VERSION=17

ARG CONFIG_SIDEBAR_DISCOVERY_FACET_LIMIT="10"
ARG CONFIG_DSPACE_ACTIVE_THEME="THEME_NAME"
ARG DSPACE_INSTALL=/dspace

# Step 1 - Run Maven Build
FROM dspace/dspace-dependencies:dspace-7_x AS build
ARG TARGET_DIR=dspace-installer
WORKDIR /app
# The dspace-installer directory will be written to /install
RUN mkdir /install \
    && chown -Rv dspace: /install \
    && chown -Rv dspace: /app
USER dspace
# Copy the DSpace source code (from local machine) into the workdir (excluding .dockerignore contents)
ADD --chown=dspace . /app/

# Copy customized DSpace local.cfg
COPY --chown=dspace:dspace config/local.cfg "$DSPACE_INSTALL"/config/

# Add additional org.dspace.discovery.configuration.DiscoveryConfiguration
RUN if [ -f org.dspace.discovery.configuration.DiscoveryConfiguration.xml ]; \
    then sed -i -e '/#CONFIG_SPRING_API_DISCOVERY_SIDEBAR_SEARCH_ADDITIONAL#/{r org.dspace.discovery.configuration.DiscoveryConfiguration.xml' -e 'd}' /app/dspace/config/spring/api/discovery.xml; \
    else sed -i -e 's/#CONFIG_SPRING_API_DISCOVERY_SIDEBAR_SEARCH_ADDITIONAL#//g' /app/dspace/config/spring/api/discovery.xml \
        && echo "CONFIG_SPRING_API_DISCOVERY_SIDEBAR_SEARCH_ADDITIONAL IS NOT EXISTS"; \
    fi \
# Add additional org.dspace.discovery.configuration.DiscoveryConfiguration.details details
    && if [ -f org.dspace.discovery.configuration.DiscoveryConfiguration.details.xml ]; \
    then sed -i -e '/#CONFIG_SPRING_API_DISCOVERY_SIDEBAR_SEARCH_DETAILS_ADDITIONAL#/{r org.dspace.discovery.configuration.DiscoveryConfiguration.details.xml' -e 'd}' /app/dspace/config/spring/api/discovery.xml; \
    else sed -i -e 's/#CONFIG_SPRING_API_DISCOVERY_SIDEBAR_SEARCH_DETAILS_ADDITIONAL#//g' /app/dspace/config/spring/api/discovery.xml \
        && echo "CONFIG_SPRING_API_DISCOVERY_SIDEBAR_SEARCH_DETAILS_ADDITIONAL IS NOT EXISTS"; \
    fi \
# Set facet limit
    && sed -i -e "s/#CONFIG_SIDEBAR_DISCOVERY_FACET_LIMIT#/$CONFIG_SIDEBAR_DISCOVERY_FACET_LIMIT/g" \
           /app/dspace/config/spring/api/discovery.xml \
# Add additional org.dspace.discovery.configuration.DiscoveryMoreLikeThisConfiguration
    && if [ -f org.dspace.discovery.configuration.DiscoveryMoreLikeThisConfiguration.xml ]; \
    then sed -i -e '/#CONFIG_SPRING_API_DISCOVERY_SIMILARITY_METADATA_ADDITIONAL#/{r org.dspace.discovery.configuration.DiscoveryMoreLikeThisConfiguration.xml' -e 'd}' /app/dspace/config/spring/api/discovery.xml; \
    else sed -i -e 's/#CONFIG_SPRING_API_DISCOVERY_SIMILARITY_METADATA_ADDITIONAL#//g' /app/dspace/config/spring/api/discovery.xml \
        && echo "CONFIG_SPRING_API_DISCOVERY_SIMILARITY_METADATA_ADDITIONAL IS NOT EXISTS"; \
    fi

# Build DSpace (note: this build doesn't include the optional, deprecated "dspace-rest" webapp)
# Copy the dspace-installer directory to /install.  Clean up the build to keep the docker image small
# Maven flags here ensure that we skip building test environment and skip all code verification checks.
# These flags speed up this compilation as much as reasonably possible.
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
ENV MAVEN_FLAGS="-Denforcer.skip=true -Dcheckstyle.skip=true -Dlicense.skip=true -Dxml.skip=true -Pdspace-rest"
RUN mvn --no-transfer-progress package ${MAVEN_FLAGS} && \
  mv /app/dspace/target/${TARGET_DIR}/* /install && \
  mvn clean
# Remove the server webapp to keep image small.
RUN rm -rf /install/webapps/server/

# Step 2 - Run Ant Deploy
FROM eclipse-temurin:${JDK_VERSION} AS ant_build
ARG TARGET_DIR=dspace-installer
# COPY the /install directory from 'build' container to /dspace-src in this container
COPY --from=build /install /dspace-src
WORKDIR /dspace-src
# Create the initial install deployment using ANT
ENV ANT_VERSION 1.10.13
ENV ANT_HOME /tmp/ant-$ANT_VERSION
ENV PATH $ANT_HOME/bin:$PATH
# Need wget to install ant
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*
# Download and install 'ant'
RUN mkdir $ANT_HOME && \
    wget -qO- "https://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C $ANT_HOME
# Run necessary 'ant' deploy scripts
RUN ant init_installation update_configs update_code update_webapps

# Step 3 - Run tomcat
# Create a new tomcat image that does not retain the the build directory contents
FROM tomcat:9-jdk${JDK_VERSION}
# NOTE: DSPACE_INSTALL must align with the "dspace.dir" default configuration.
ENV DSPACE_INSTALL=/dspace
# Copy the /dspace directory from 'ant_build' container to /dspace in this container
COPY --from=ant_build /dspace $DSPACE_INSTALL
# Expose Tomcat port and AJP port
EXPOSE 8080 8009
# Give java extra memory (2GB)
ENV JAVA_OPTS=-Xmx2000m

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y \
    postgresql-client \
    imagemagick \
    ghostscript \
    cron \
    less \
    vim \
    schedtool \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove

# Install root filesystem
COPY rootfs /

# Copy Handle server
RUN if [ -d /app/custom_configuration/themes/$CONFIG_DSPACE_ACTIVE_THEME/handle-server ]; \
        then cp -r /app/custom_configuration/themes/$CONFIG_DSPACE_ACTIVE_THEME/handle-server $DSPACE_INSTALL/; \
        else echo "No Handle server files found"; \
    fi \
    # Make sure the crontab uses the correct DSpace directory
    && sed -i "s#DSPACE=/dspace#DSPACE=$DSPACE_INSTALL#g" /etc/cron.d/dspace-maintenance-tasks \
    && rm -rf /tmp/* \
    && chmod 644 /etc/cron.d/dspace-maintenance-tasks

COPY GeoLite2-City/GeoLite2-City.mmdb "$DSPACE_INSTALL"/config/

# Link the DSpace 'server' webapp into Tomcat's webapps directory.
# This ensures that when we start Tomcat, it runs from /server path (e.g. http://localhost:8080/server/)
RUN ln -s $DSPACE_INSTALL/webapps/server "$CATALINA_HOME"/webapps/server
# If you wish to run "server" webapp off the ROOT path, then comment out the above RUN, and uncomment the below RUN.
# You also MUST update the 'dspace.server.url' configuration to match.
# Please note that server webapp should only run on one path at a time.
#RUN mv /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT.bk && \
#    ln -s $DSPACE_INSTALL/webapps/server   /usr/local/tomcat/webapps/ROOT

# Copy legacy REST API Tomcat config
COPY config/rest.xml "$CATALINA_HOME"/conf/Catalina/localhost/
# Overrides the requirement to connect to the legacy rest service over https
COPY config/rest_web.xml "$DSPACE_INSTALL"/webapps/rest/WEB-INF/web.xml

RUN useradd -r -s /bin/bash -m -d "$DSPACE_INSTALL" dspace
RUN chown -R dspace:dspace "$DSPACE_INSTALL" "$CATALINA_HOME"

ENV DSPACE_VERSION=7_x
# Build info
RUN echo "Debian GNU/Linux `cat /etc/debian_version` image. (`uname -rsv`)" >> /root/.built \
    && echo "- with `java -version 2>&1 | awk 'NR == 2'`" >> /root/.built \
    && echo "- with DSpace $DSPACE_VERSION on Tomcat $TOMCAT_VERSION"  >> /root/.built \
    && echo "\nNote: if you need to run commands interacting with DSpace you should enter the" >> /root/.built \
    && echo "container as the dspace user, ie: docker exec -it -u dspace dspace /bin/bash" >> /root/.built

USER dspace