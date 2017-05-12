#!/usr/bin/bash
dir=`pwd`
#echo $dir
#find $dir -type f -name "*filename*"
#readlink -f serverlist.csv
path=$dir/decom_servers.csv
fname=$(basename "$path")
#echo "$name"
 		#echo "*******************"
		#echo "Commissioning Node."
		#echo "*******************"
		#echo "Give the Name of the File"
		#read fname
		#echo "**********************"
		#echo "Decommissioning Node.."
		#echo "**********************"
		#echo "Give the Name of the file"
		#read fname
		if [ -f "$fname" ]
		then
			rm -rf $HADOOP_HOME/excludes
			#echo "$fname is exist.."
			#while IFS= read line
			cat $fname | sed '/^\s*$/d' | while read line
			do 
				input=`echo "$line"`
				path=`echo $HADOOP_HOME`
				ping -c 1 "$input">/dev/null 
				if [ $? -eq 0 ]; then				
					if ! grep -q "$input" $path/excludes -R -n 2>/dev/null
					then
						echo "$input" >>$path/excludes	
					fi					
				fi										
			done 

			path=`echo $HADOOP_HOME/etc/hadoop`
			cd $path 
			cat yarn-site.xml | echo -e $HADOOP_HOME | sed -i '/includes/d' yarn-site.xml
			cat hdfs-site.xml | echo -e $HADOOP_HOME | sed -i '/includes/d' hdfs-site.xml

			if [ -f $path/yarn-site.xml ] 
			then
				if ! grep -q "excludes" $path/yarn-site.xml  -R -n 2>/dev/null
				then
				
					cat yarn-site.xml | sed -i  '/\/configuration/i 	<property><name>yarn.resourcemanager.node.exclude-path</name><value>'$HADOOP_HOME'/excludes</value> </property>' yarn-site.xml					
			
				fi
			fi


			if [ -f $path/hdfs-site.xml ]
			then
				if ! grep -q "excludes" $path/hdfs-site.xml  -R -n 2>/dev/null
				then
					cat yarn-site.xml | sed -i  '/\/configuration/i 	<property><name>dfs.hosts.exclude</name><value>'$HADOOP_HOME'/excludes</value> </property>' hdfs-site.xml 
				fi
			fi
			#yarn rmadmin -refreshNodes
			hadoop dfsadmin -refreshNodes 
			cat yarn-site.xml | echo -e $HADOOP_HOME | sed -i '/excludes/d' yarn-site.xml
			cat hdfs-site.xml | echo -e $HADOOP_HOME | sed -i '/excludes/d' hdfs-site.xml
		
		else
			echo "$fname is not Exist..."
			
		fi
