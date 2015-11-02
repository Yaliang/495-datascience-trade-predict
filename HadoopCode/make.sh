#!/bin/bash

# replace the follow class path to the JDK's library tools.jar path
export HADOOP_CLASSPATH=/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar


currentInt=3

# into the Hadoop root path
cd ~/Documents/Hadoop/hadoop-2.7.1

# compile the Hadoop application
bin/hadoop com.sun.tools.javac.Main code/FindLargestBusiness.java 

# format a jar package
cd code/
jar cf flb.jar FindLargestBusiness*.class

# into the Hadoop root path
cd ..

# run the standalone mode Hadoop
bin/hadoop jar code/flb.jar FindLargestBusiness ~/Documents/Hadoop/hadoop-2.7.1/input/ ~/Documents/Hadoop/hadoop-2.7.1/output/${currentInt}/
# part-r-00000 is the result