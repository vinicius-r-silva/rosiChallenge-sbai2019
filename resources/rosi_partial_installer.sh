#!/bin/bash

# support variables
vrep_folder=$HOME'/.vrepTeste' #vrep folder location

#colors for echo
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# messages to the user
echo -e "${GREEN}=========================================${NC}"
echo -e "${BLUE}** ROSI CHALLENGE SIMULATOR INSTALLER **${NC}\n"

echo -e "${BLUE}First, tell me where is located your catkin_ws folder (example: /home/john/vrep):${NC}"
read var_catkin_ws_folder

echo -e "\n${BLUE}Do you use bash or zsh? (answer: bash, zsh)${NC}"
read var_shell

# treats the rc file
if [[ $var_shell == "zsh" ]]; then
	editorc=".zshrc"
elif [[ $var_shell == "bash" ]]; then
	editorc=".bashrc"
fi

# install some support packages
echo -e "${BLUE}Installing some support packages\n${ORANGE}We need your sudo password here:${NC}"
sudo apt update
sudo apt install python-catkin-tools xsltproc ros-$ROS_DISTRO-brics-actuator ros-$ROS_DISTRO-tf2-sensor-msgs ros-$ROS_DISTRO-joy

# downloads V-REP
echo -e "\n${BLUE}Downloading V-REP from Coppelia Robotics server.${NC}"
wget http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_6_2_Ubuntu18_04.tar.xz

# extract, move and delete V-REP folder
echo -e "\n${BLUE}Extracting V-REP to $vrep_folder.${NC}"
tar -xf ./V-REP_PRO_EDU_V3_6_2_Ubuntu18_04.tar.xz 
mv ./V-REP_PRO_EDU_V3_6_2_Ubuntu18_04 $vrep_folder
rm -rf ./V-REP_PRO_EDU_V3_6_2_Ubuntu18_04.tar.xz

# insert some stuff into bashrc or zshrc
echo -e "${BLUE}Adding some lines to $HOME/editorc.${NC}"

echo -e "\n#ROSI SIMULATION additions " >> $HOME/$editorc
echo "export ROS_CATKIN_WS='$var_catkin_ws_folder'" >> $HOME/$editorc
echo "export VREP_ROOT='$vrep_folder'" >> $HOME/$editorc
echo "alias vrepTeste='$vrep_folder/vrep.sh'" >> $HOME/$editorc

#sourcing again bashrc
echo -e "${BLUE}Sourcing $HOME/$editorc.${NC}"
source $HOME/$editorc

#clones the vrep_ros_interface
echo -e "${BLUE}Cloning the V-REP ROS Interface into $ROS_CATKIN_WS/src/vrep_ros_interface.${NC}"
git clone --recursive https://github.com/CoppeliaRobotics/v_repExtRosInterface.git $ROS_CATKIN_WS/src/vrep_ros_interface

#adding ROSI messages to the vrep_ros_interface
echo -e "${BLUE}Adding custom ROSI simulator messages to vrep_ros_interface files.${NC}"
echo -e "rosi_defy/ManipulatorJoints\nrosi_defy/RosiMovement\nrosi_defy/RosiMovementArray" >> $ROS_CATKIN_WS/src/vrep_ros_interface/meta/messages.txt
sed -i '33i\  <depend>rosi_defy</depend>' $ROS_CATKIN_WS/src/vrep_ros_interface/package.xml
sed -i '27i\    rosi_defy' $ROS_CATKIN_WS/src/vrep_ros_interface/CMakeLists.txt

# cleaning and re-compiling the workspace
echo -e "${BLUE}Cleaning and Re-compiling the ROS workspace\n${ORANGE}Select 'YES' when asked if you want to remove catkin_ws directories.${NC}"
cd $ROS_CATKIN_WS
catkin clean 
catkin build
source $HOME/$editorc

# copying the vrep library to vrep_root
echo -e "${BLUE}Copying vrep_ros_interface library to VREP_ROOT.${NC}"
cp $ROS_CATKIN_WS/devel/lib/libv_repExtRosInterface.so $vrep_folder

#sourcing again bashrc
echo -e "${BLUE}Sourcing $HOME/$editorc.${NC}"
source $HOME/$editorc

# final messages 
echo -e "${GREEN}\n\nFinished installing and configuring V-REP and ROS interface."
echo -e "${GREEN}Now you can run V-REP in terminal using the command ${ORANGE}vrep${BLUE}.${NC}"
echo -e "${GREEN}Check if everything is OK since this code does not check its actions.${NC}"
echo -e "${GREEN}=========================================${NC}"