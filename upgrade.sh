#!/usr/bin/sh

hpath=$(echo "$HADOOP_HOME/etc/hadoop")
currentPath=`pwd`
echo -e "************************************************\n"
echo -e "Stopping the Dfs daemons...\n"
echo -e "************************************************\n"
echo `stop-dfs.sh`

echo -e "************************************************\n"
echo -e "Stopping the Yarn daemons...\n"
echo -e "************************************************\n"
echo `stop-yarn.sh`

cd $hpath
echo -e "************************************************\n"
echo -e "Taking Backup of the old version config files...\n"
echo -e "************************************************\n"
cp core-site.xml hdfs-site.xml yarn-site.xml mapred-site.xml hadoop-env.sh ~/
sleep 5
upgrade_path=$currentPath/upgrade

if [ -d "${upgrade_path}" ] ; then
    	echo "Upgrade  exits"
	cd $upgrade_path

	hadoop_file=`ls | egrep -e ".tar.gz"`
	echo $hadoop_file
	cwd=`pwd`

	if [ -f "${hadoop_file}" ]
	then
		echo "File $hadoop_file exits"
		
		sleep 15
		mkdir hadoop_old
		echo -e "Moving old version file to the hadoop old folder"
		mv $HADOOP_HOME/* hadoop_old
		sleep 25
		echo -e "************************************************\n"
		echo -e "Extracting the hadoop installation tar zip file....\n"
		echo -e "************************************************\n"
		
		tar -xzf $hadoop_file
		
		
		extract_file=`echo $hadoop_file | sed -n '/\.tar\.gz$/s///p'`

		
		echo -e "moving the extracted hadoop installation file to user home directory..."
		mv $extract_file hadoop
		sleep 15
		mv hadoop/* $HADOOP_HOME/
		sleep 15
		cd ~/
		mv core-site.xml yarn-site.xml hdfs-site.xml mapred-site.xml hadoop-env.sh $HADOOP_HOME/etc/hadoop

		sleep 15
		echo -e "************************************************\n"
		echo -e "Starting the Hadoop Upgrade .... Please wait a moment....\n"
		echo -e "************************************************\n"
		echo `hadoop-daemon.sh start namenode -upgrade`
		#echo `hdfs dfsadmin -upgradeProgress status`
		echo `hdfs dfsadmin -finalizeUpgrade`
		#echo `hadoop dfs ls -R / > dfs-v-new-lsr-0.log`

		sleep 10
		
		echo -e "************************************************\n"
		echo -e "Starting the DFS Daemon in the clusters...\n"
		echo -e "************************************************\n"
		echo `start-dfs.sh`
		echo -e "************************************************\n"
		echo -e "Starting the YARN Daemon in the clusters...\n"
		echo -e "************************************************\n"
		echo `start-yarn.sh`
	else

		echo "$0: $hadoop_file not found."
		exit
	fi

fi







