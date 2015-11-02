#!/bin/bash

export HADOOP_CLASSPATH=/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar


currentInt=3

cd ~/Documents/Hadoop/hadoop-2.7.1

bin/hadoop com.sun.tools.javac.Main code/FindLargestBusiness.java 

cd code/

jar cf flb.jar FindLargestBusiness*.class

cd ..

bin/hadoop jar code/flb.jar FindLargestBusiness ~/Documents/Hadoop/hadoop-2.7.1/input/ ~/Documents/Hadoop/hadoop-2.7.1/output/${currentInt}/

