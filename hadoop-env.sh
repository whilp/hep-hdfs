# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.  Required.
export JAVA_HOME=/usr/java/latest

# Extra Java CLASSPATH elements.  Optional.
HADOOP_CLASSPATH=$HADOOP_CONF_DIR:$(build-classpath hadoop)

# The maximum amount of heap to use, in MB. Default is 1000.
export HADOOP_HEAPSIZE=8192

# Java JMX options.
# Leave JMX disabled by default.
export HADOOP_JMX_OPTS=""
#export HADOOP_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8686"
# Insecure JMX settings that should work, but will allow anyone to access
# the jvm.
#export HADOOP_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8686 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# Command specific options appended to HADOOP_OPTS when specified
export HADOOP_NAMENODE_OPTS="$HADOOP_JMX_OPTS $HADOOP_NAMENODE_OPTS"
export HADOOP_SECONDARYNAMENODE_OPTS="$HADOOP_JMX_OPTS $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="$HADOOP_JMX_OPTS $HADOOP_DATANODE_OPTS"
export HADOOP_BALANCER_OPTS="$HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="$HADOOP_JMX_OPTS $HADOOP_JOBTRACKER_OPTS"
# export HADOOP_TASKTRACKER_OPTS=
# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
# export HADOOP_CLIENT_OPTS

# Extra ssh options.  Empty by default.
# export HADOOP_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"

# Where log files are stored.  $HADOOP_HOME/logs by default.
HADOOP_LOG_DIR=/var/log/hadoop

# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1

# The directory where pid files are stored. /tmp by default.
export HADOOP_PID_DIR=/var/run/hadoop

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10

export HADOOP_NAMEPORT=9000
export HADOOP_DATADIR=/data/hdfs
export HADOOP_LOG=/data/hdfs/logs
export HADOOP_SCRATCH=/data/hdfs/scratch
export POOL_DATA_SIZE_MIN=300

