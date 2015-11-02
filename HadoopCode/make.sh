#!/bin/bash

# replace the follow class path to the JDK's library tools.jar path
export HADOOP_CLASSPATH=/usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar

currentInt=3

# into the Hadoop root path
cd ~/Documents/Hadoop/hadoop-2.7.1

# compile the Hadoop application
# bin/hadoop com.sun.tools.javac.Main <pathToJavaCode>/<JavaFile>
bin/hadoop com.sun.tools.javac.Main code/FindLargestBusiness.java 

# go to source code folder
cd code/

# build a jar package
jar cf flb.jar FindLargestBusiness*.class

# back to the Hadoop root path
cd ..

# run the standalone mode Hadoop
# bin/hadoop jar <pathToJavaArchive>/<JavaArchiveFile> <classIncludeMain> <pathToInputFolder> <pathToOuputFolder>
bin/hadoop jar code/flb.jar FindLargestBusiness ~/Documents/Hadoop/hadoop-2.7.1/input/ ~/Documents/Hadoop/hadoop-2.7.1/output/${currentInt}/
