#########################################################
# Create an image that holds SteamCMD client inside it
# You can use this as basis for you own dedicated server
#########################################################
FROM ubuntu:23.04 

ARG UID=1001
ARG USER=steam
ARG USER_PASSWD=steam
ARG USER_HOME_DIR=/home/$USER
ARG TZ="Europe/Madrid"

ARG STEAM_HOME_DIR=$USER_HOME_DIR/Steam

# Set timezone
ENV TZ=$TZ

# Update & upgrade the system
RUN apt update -y && apt upgrade -y --no-install-recommends --no-install-suggests && \
    apt install -y apt-utils software-properties-common curl tzdata locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

# Add multiverse repo, set 386 architecture needed to install steamcmd
RUN add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt update -y && \
    apt install -y lib32gcc-s1 

# Clean up
RUN apt remove --purge --auto-remove -y && \
    rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -rm -d $USER_HOME_DIR -s /bin/bash -g root -G sudo -u $UID $USER -p $USER_PASSWD

USER $USER
WORKDIR $STEAM_HOME_DIR

# Dowload & install & update SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - && \
    ./steamcmd.sh +quit

# Make steamclient.so library available in the system
USER root
RUN ln -s "$STEAMCMD_DIR/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so"

# END SteamCMD isnstallation