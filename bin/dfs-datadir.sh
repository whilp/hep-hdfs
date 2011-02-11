MOUNTS=/proc/mounts
HDFSSITE=/etc/hadoop/conf/hdfs-site.xml
TEMPLATE="${HDFSSITE}.in"
PIDFILE=/var/run/hadoop/hadoop-hadoop-datanode.pid
TESTDIRS=""

mounts () {
    local MOUNTS="${1:-${MOUNTS}}"
    while read PART MNT OPTS FREQ PASS; do
        case "${MNT}" in "${DATAROOT%/}"/*) echo "${MNT}";; esac
    done < "${MOUNTS}"
}

iswritable () {
    TESTDIR=$(mktemp -p "${1%/}" -d ".datanode-disks-XXXXXXXX" 2>/dev/null)
    trap "rm -rf ${TESTDIR}" RETURN ERR EXIT

    TESTFILE="${TESTDIR}/testfile"

    OK=1
    echo "test" > "${TESTFILE}"
    if [ "$(< ${TESTFILE})" == "test" ]; then
        OK=0
        rm -rf "${TESTDIR}"
        [ -d "${TESTDIR}" ] && OK=1
    fi
    return "${OK}"
}

usage () {
    echo -e "Usage: $0 [options] <dataroot>"
    echo -e "\t-m   mounts file (default: ${MOUNTS})"
    echo -e "\t-p   PID file (default: ${PIDFILE})"
    echo -e "\t-s   path to hdfs-site.xml (default: ${HDFSSITE})"
    echo -e "\t-t   path to hdfs-site.xml template (default: ${TEMPLATE})"
}

while getopts m:p:s:t:hrv ARG; do
    case "${ARG}" in
        m) MOUNTS="${OPTARG}";;
        p) PIDFILE="${OPTARG}";;
        s) HDFSSITE="${OPTARG}";;
        t) TEMPLATE="${OPTARG}";;
        h) usage; exit 0;;
        r) REMOVE=1;;
        v) VERBOSE=1;;
        *) usage; exit 1;;
    esac
done
shift $(($OPTIND - 1))

DATAROOT=$1

DFSDATADIR=""
for MOUNT in $(mounts "${DATAROOT}"); do
    if iswritable "${MOUNT}"; then
        HDFSDIR="${MOUNT}/hdfs"
        [ -d "${HDFSDIR}" ] && DFSDATADIR="${DFSDATADIR},${HDFSDIR}"
    fi
done
DFSDATADIR="${DFSDATADIR#,}"

TMPFILE="$(mktemp ${TEMPLATE}.XXXXXX)"
trap "rm -f ${TMPFILE}" ERR EXIT
eval "echo \"$(< ${TEMPLATE})\"" > "${TMPFILE}"

if ! cmp -s "${TMPFILE}" "${HDFSSITE}" 2>/dev/null; then
    mv "${TMPFILE}" "${HDFSSITE}"

    /etc/init.d/hadoop stop
    while kill -0 "$(< "${PIDFILE}")" 2>/dev/null; do
        sleep 1
    done
    /etc/init.d/hadoop start
fi
