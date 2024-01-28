##############################################################################
##                           1. stage: Base Image                           ##
##############################################################################
ARG ROS_DISTRO=humble
FROM osrf/ros:$ROS_DISTRO-desktop as base

# Configure DDS
COPY dds_profile.xml /opt/misc/dds_profile.xml
ENV FASTRTPS_DEFAULT_PROFILES_FILE=/opt/misc/dds_profile.xml

# Create user
ARG USER=hephaestus
ARG UID=1000
ARG GID=1000
ENV USER=$USER
RUN groupadd -g $GID $USER \
    && useradd -m -u $UID -g $GID --shell $(which bash) $USER

#install xacro and joint state publisher gui package (additional necessarity when not using the ur-package from ros)
USER root
RUN apt-get update && apt-get install -y ros-humble-xacro
RUN apt-get update && apt-get install -y ros-humble-joint-state-publisher-gui
USER ${USER}

# Setup workpace
USER $USER
RUN mkdir -p /home/$USER/ros2_ws/src
WORKDIR /home/$USER/ros2_ws


##############################################################################
##       2. stage: clone the robotarm-description repo from github          ##
##############################################################################
FROM base as diy_robotarm

# Install git to clone diy-soft-robotarm-description packages
USER root
RUN apt-get update && apt-get install --no-install-recommends -y git
USER $USER

# Clone the diy-soft-robotarm-description package into its own workspace
RUN mkdir -p /home/$USER/dependencies/diy_robotarm_wer24_description_ws/src
RUN cd /home/$USER/dependencies/diy_robotarm_wer24_description_ws/src && \
    git clone https://github.com/RobinWolf/diy_robotarm_wer24_description.git

# Build the diy-robotarm package
RUN cd /home/$USER/dependencies/diy_robotarm_wer24_description_ws && \
    . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build

# Add built diy-robotarm package to entrypoint
USER root
RUN sed -i 's|exec "\$@"|source "/home/'"${USER}"'/dependencies/diy_robotarm_wer24_description_ws/install/setup.bash"\n&|' /ros_entrypoint.sh
USER $USER

##############################################################################
##               3. stage: robotarm visualisation (deployment)               ##
##############################################################################

# Add a default command to start visualization of the robotarm by default whrn buildung the container
CMD ["ros2", "launch", "diy_robotarm_wer24_description", "visualize.launch.py", "use_fake_hardware:=false"]