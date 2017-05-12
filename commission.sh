#!/usr/bin/bash
dir=`pwd`
#echo $dir
#find $dir -type f -name "*filename*"
#readlink -f serverlist.csv
path=$dir/com_servers.csv
fname=$(basename "$path")
#echo "$name"
 		
 		#echo "*******************"
		#echo "Commissioning Node."
		#echo "*******************"
		#echo "Give the Name of the File"
		#read fname
		if [ -f "$fname" ]
		then
			#echo "$fname is exist.."
			rm -rf $HADOOP_HOME/includes
			
			#while IFS= read line 
			cat $fname | sed '/^\s*$/d' | while read line
			do 
				input=`echo "$line"`
				path=`echo $HADOOP_HOME`
				ping -c 1 "$input">/dev/null 
				if [ $? -eq 0 ]; then
					#echo "Node $input is UP.."
					if ! grep -q "$input" $path/includes -R -n 2>/dev/null
					then
						echo "$input" >>$path/includes	
					fi				
				fi		
								
			done 
			
			cd $HADOOP_HOME/etc/hadoop
			#cat yarn-site.xml | sed -i '/\/opt\/hadoop\/excludes/d' yarn-site.xml
			cat yarn-site.xml | echo -e $HADOOP_HOME | sed -i '/excludes/d' yarn-site.xml
			cat hdfs-site.xml | echo -e $HADOOP_HOME | sed -i '/excludes/d' hdfs-site.xml

			if [ -f $HADOOP_HOME/etc/hadoop/yarn-site.xml ]
			then
				if ! grep -q "includes" $path/etc/hadoop/yarn-site.xml  -R -n 2>/dev/null
			then
				
				cat yarn-site.xml | sed -i  '/\/configuration/i 	<property><name>yarn.resourcemanager.node.include-path</name><value>'$HADOOP_HOME'/includes</value> </property>' yarn-site.xml					
			
				fi
			fi
			if [ -f $HADOOP_HOME/etc/hadoop/hdfs-site.xml ]
			then
				if ! grep -q "includes" $path/etc/hadoop/hdfs-site.xml  -R -n 2>/dev/null
			then
				
				cat yarn-site.xml | sed -i  '/\/configuration/i 	<property><name>dfs.hosts</name><value>'$HADOOP_HOME'/includes</value> </property>' hdfs-site.xml					
			
				fi
			fi
			hadoop dfsadmin -refreshNodes 
			cat yarn-site.xml | echo -e $HADOOP_HOME | sed -i '/includes/d' yarn-site.xml
			cat hdfs-site.xml | echo -e $HADOOP_HOME | sed -i '/includes/d' hdfs-site.xml
					
		else
			echo "$fname is not Exist.."
		fi

