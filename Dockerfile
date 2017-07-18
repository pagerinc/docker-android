FROM ubuntu:xenial

MAINTAINER Alex Ruzzarin <alex@pager.com>

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm \
    ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" \
    ANDROID_BUILD_TOOLS_VERSION=25.0.3 \
    ANDROID_PLATFORM_APIS="android-25" \
    NODEJS_VERSION=6.10.3 \
    NPM_VERSION=5.0.1 \
    CORDOVA_VERSION=7.0.1 \
    JAVA_HOME="/usr/lib/jvm/java-8-oracle" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:/opt/node/bin

WORKDIR /opt

RUN buildDeps='software-properties-common'; \
    set -x && \
    # automatically accept the Oracle license
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \

    dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get -qq install -y $buildDeps wget curl maven ant gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386 ca-certificates --no-install-recommends && \

    # use WebUpd8 PPA
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get -qq update -y && \
    apt-get -qq install -y oracle-java8-installer oracle-java8-set-default

    # Installs Android SDK
RUN mkdir android && \
    cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && \
    rm tools.zip && \
    mkdir -p /root/.android && \
    touch /root/.android/repositories.cfg && \
    yes | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platform-tools" "platforms;${ANDROID_PLATFORM_APIS}" && \
    sdkmanager --update && \
    yes | sdkmanager --licenses && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

    # Installs Node
RUN cd /opt && \
    mkdir node && \
    cd /opt/node && \
    curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1 && \
    
    # clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get autoremove -y && \
    apt-get clean && \

    # Installs Cordova
    npm i -g --unsafe-perm npm@${NPM_VERSION} cordova@${CORDOVA_VERSION}