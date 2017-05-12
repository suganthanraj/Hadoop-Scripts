#!/usr/bin/sh
dir=`pwd`
path=$dir/single_node_servers.csv
fname=$(basename "$path")


currHostIP=$(echo `ifconfig | grep inet | head -1 | awk '{print $2}'`)
currHostName=$(echo `hostname`)
echo "Setting hosts in /etc/hosts"
echo $currHostIP $currHostName >> /etc/hosts

ssh_service=`systemctl is-enabled sshd.service`

if [ $ssh_service != "enabled" ]
then
	echo "SSH Not Configured"
	exit
fi

cat $fname | sed 's/\r//g' | while read username
do
		echo "--------- Java Version Installed on this machine------"
		echo `java -version`

		echo "creating the user for hadoop...."
		useradd  "$username" 
		egrep "^$username" /etc/passwd >/dev/null
		if [ $? -eq 1 ]; then
			useradd -p `mkpasswd "$username"` -d /home/"$username" -m -g users -s /bin/bash "$username"
			exit 1
		fi
		
		if [ ! -d "/root/.ssh" ]; then
		    echo `mkdir /root/.ssh`
		fi

		#echo `su - $username`
		echo "Generating ssh keygen................."
		echo `ssh-keygen -t rsa -P "" -f id_rsa`
		sleep 15 
		mv id_rsa id_rsa.pub ~/.ssh
		sleep 15
		echo `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`
		echo `chmod 0600 ~/.ssh/authorized_keys`
		
		echo `ssh-add`

		hadoop_file=`find . -type f -name "hadoop*"`

		cwd=`pwd`

		if [ -f "${hadoop_file}" ]
		then
			echo "File $hadoop_file exit"

			echo -e "Extracting the hadoop installation tar zip file....\n"
			#(pv -n $hadoop_file | tar zxf - -C $cwd ) 2>&1 | dialog --gauge "Extracting $hadoop_file, please wait..." 10 70 0

			tar -xzf $hadoop_file
			echo `clear`
			sleep 15
			extract_file=`echo $hadoop_file | sed -n '/\.tar\.gz$/s///p'`

			home_dir=`grep $username /etc/passwd | cut -d ':' -f6`
			sleep 10
			echo -e "moving the extracted hadoop installation file to user home directory..."
			mv $extract_file $home_dir/hadoop
			sleep 5
		else

			echo "$0: $hadoop_file not found."
			exit
		fi


		echo "Setting the environment variables for Hadoop...."

		echo "export HADOOP_HOME=$home_dir/hadoop" >> ~/.bashrc
		echo "export HADOOP_INSTALL="'$HADOOP_HOME'"" >> ~/.bashrc
		echo "export HADOOP_MAPRED_HOME="'$HADOOP_HOME'"" >> ~/.bashrc
		echo "export HADOOP_COMMON_HOME="'$HADOOP_HOME'"" >> ~/.bashrc
		echo "export HADOOP_HDFS_HOME="'$HADOOP_HOME'"" >> ~/.bashrc
		echo "export YARN_HOME="'$HADOOP_HOME'"" >> ~/.bashrc
		echo "export HADOOP_COMMON_LIB_NATIVE_DIR="'$HADOOP_HOME'"/lib/native" >> ~/.bashrc
		echo "export PATH="'$PATH:$HADOOP_HOME'"/sbin:"'$HADOOP_HOME'"/bin" >> ~/.bashrc
		sleep 5
		echo "Saving the environment variables for Hadoop..."
		source ~/.bashrc

		sleep 15
		echo "Setting JAVA HOME in hadoop environment in $HADOOP_HOME/etc/hadoop/hadoop-env.sh..."
		java_env=$(dirname $(dirname $(readlink -f $(which javac)))) 
		echo "export JAVA_HOME=$java_env" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

		sleep 15

		cd $HADOOP_HOME/etc/hadoop
		pwd

		echo "Configuring the core-site.xml file............."
		cat core-site.xml | sed -i  '/configuration/c\'  core-site.xml
		echo "<configuration>
			<property><name>fs.defaultFS</name>
				<value>hdfs://localhost:9000</value>
			</property>
		</configuration>" >> core-site.xml

		sleep 15

		echo "Configuring the hdfs-site.xml file............."
		cat hdfs-site.xml | sed -i '/configuration/c\' hdfs-site.xml
		echo "<configuration>
		<property>
		 <name>dfs.replication</name>
		 <value>1</value>
		</property>

		<property>
		  <name>dfs.name.dir</name>
		    <value>file:///home/$username/hadoopdata/hdfs/namenode</value>
		</property>

		<property>
		  <name>dfs.data.dir</name>
		    <value>file:///home/$username/hadoopdata/hdfs/datanode</value>
		</property>
		</configuration>" >> hdfs-site.xml

		sleep 15
		cp mapred-site.xml.template mapred-site.xml

		echo "Configuring the mapred-site.xml file............."
		cat mapred-site.xml | sed -i '/configuration/c\' mapred-site.xml
		echo "<configuration>
		 <property>
		  <name>mapreduce.framework.name</name>
		   <value>yarn</value>
		 </property>
		</configuration>" >> mapred-site.xml
		sleep 15
		echo "Configuring the yarn-site.xml file............"
		cat yarn-site.xml | sed -i '/configuration/c\' yarn-site.xml
		echo "<configuration>
		 <property>
		  <name>yarn.nodemanager.aux-services</name>
		    <value>mapreduce_shuffle</value>
		 </property>
		</configuration>" >> yarn-site.xml

		sleep 15

		cd $HADOOP_HOME/bin

		echo "Formatting the HDFS namenode................"
		echo `hdfs namenode -format`

		sleep 15

		cd $HADOOP_HOME/sbin/

		echo "Starting the dfs................"
		sh start-dfs.sh

		echo "Starting the yarn................"
		sh start-yarn.sh

		echo "Started Opening the console in the browser........"

		firefox=`which firefox`

		echo -e `$firefox -new-tab -url $currHostName:50070 -new-tab -url $currHostName:50090 -new-tab -url $currHostName:8042 -new-tab -url $currHostName:8088`

done

exit


