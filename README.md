# DIY-RobotArm-WER24-Description

## thematical Classification
This repository contains a ROS2 package for the 3D-printed robot arm, designed by LOBOCNC and published on Printables (https://www.printables.com/model/132260-we-r24-six-axis-robot-arm and https://www.printables.com/model/132262-robot-actuators)
We use this ur-3 copy as a base modified for our purposes. For a full description of the hardware-build process please refert to the DIY-Robotics-Hardware repo.

The main idea is, that this repo can be cloned inside a docker-container containing and combining all description packages for the whole scene (e.g. Base, Robot, Gripper, additional obstacles) Using differnet docker containers is very likely, because this makes the whole integration very modular.

Refer to the main Readme.md https://github.com/mathias31415/diy_robotics/blob/main/ROS-Packages/ROS-OVERVIEW.md for a general overview.

![arm_classification](images/arm_classification.png)

## Package Structure

![arm_files_tree](images/arm_files_tree.png)

 - images and README.md are only for docomentation purposes
 - Dockerfile, run.sh and dds_profile.xml are used to create the docker container where ROS is running in
 - build, install ansd log are directories created by ROS when building the package with ament_cmake
 - CMakeLists.txt and package.xml are defining this build process (wich dependencies are needed, which file should be installed where in the created directories, ...)
 - meshes, rviz, urdf, config and launch are the directories which are containing the source files for this package, they will be described in the following

## URDF Definition

For this URDF definition we use the ROS xacro extention to ensure clear structures and the best modularity.
In addition to the xacro sub-urdf definitions we have implemented the usage of several confuguration files in the "config" directory.

On the one side there is the default_kinematics.yaml file which contains all of the kinematical properties (position and orientation of the joints, xyz and rpy) and on the other side there is the joint_limits.yaml which contains joint limits (position, velocity, acceleration and effort). Don't be surprised why all joints are specified with position limits of +/-pi, that are not our real motion limits. We have decided to define position limits on the ESP32 hardware-driver side, which are checked before a new setpoint is set. So the config file only is taken into account if you are using fake_hardware. If you are using real_hardware, the limits specified on the ESP32 side are taken into account.

The following graphic shows how the full URDF definition of the arm was build and which parameters are passed in between the diffrent macros.
![urdf_structure](images/urdf_structure.png)

The whole CAD robot arm model with its 6 links and 6 joints was CAD-designed in respect to the dernavit-hartenberg convention. This is a common practice to describe kinematics in robotics.
So all exported link-meshes had already their right oriented reference set. That's why we can specify the link origins in equal to the joint origin which connects the specific link to its parent.
The graphic below shows the full kinematic chain of our arm (from world to link_6/ flange) with reference sets in respect to dernavit hartenberg convention.

![dh_kos](images/dh_kos.png)





## Launch
