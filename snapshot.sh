#!/usr/bin/bash

while IFS=, read -r FName
do
	echo $FName
	
	echo "Creating a folder to take snapshots..."
	hdfs dfs -mkdir /$FName
	
	sleep 10
	
	echo "Allowing a Snapshot in the folder /$FName..."
	hdfs dfsadmin -allowSnapshot /$FName

 	sleep 10
	for i in {1..20};
	do 
		dd if=/dev/urandom bs=1 count=1 of=file$i.txt ; 
		hadoop fs -put  file$i.txt /$FName
        done

	sleep 10
	echo "Creating a Snapshot in the folder /$FName..."
	hdfs dfs -createSnapshot /$FName
done < "snapshots.csv"
		
