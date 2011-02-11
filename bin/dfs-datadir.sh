MOUNTS=/proc/mounts
HDFSSITE=/etc/hadoop/conf/hdfs-site.xml
TEMPLATE="${HDFSSITE}.in"
PIDFILE=/var/run/hadoop/hadoop-hadoop-datanode.pid
STARTSTOP=
TESTDIRS=""

mounts () {
    DATAROOT=$1
    sort -k2 "${MOUNTS}" | while read PART MNT OPTS FREQ PASS; do
        case "${MNT}" in "${DATAROOT%/}"/*) echo "${MNT}";; esac
    done
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
    echo -e "  -S           don't issue start/stop commands if hdfs-site.xml changes"
    echo -e "  -m MOUNTS    mounts file (default: ${MOUNTS})"
    echo -e "  -p PIDFILE   PID file (default: ${PIDFILE})"
    echo -e "  -s HDFSSITE  path to hdfs-site.xml (default: ${HDFSSITE})"
    echo -e "  -t TEMPLATE  path to hdfs-site.xml template (default: ${TEMPLATE})"
}

while getopts Sm:p:s:t:hrv ARG; do
    case "${ARG}" in
        S) STARTSTOP=1;;
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

DATAROOT=${1:-/data}

LOCKFILE=/var/lock/dfs-datadir.lock
LAST=$(stat -c '%Y' "${LOCKFILE}" 2>/dev/null)
if [ -n "${LAST}" ]; then
    NOW=$(date "+%s")
    if [ "$(($NOW - $LAST))" -gt 1200 ]; then
        # BREAK
        PID=$(< "${LOCKFILE}")
        if kill -0 "${PID}" 2>/dev/null; then
            echo "===> Breaking stale lock '${LOCKFILE}' owned by PID $PID"
            kill -9 "${PID}"
        fi
    else
        exit
    fi
fi
rm -f "${LOCKFILE}"; echo $$ >| "${LOCKFILE}"

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

if [ -n "${STARTSTOP}" ]; then
    exit 0
fi

if ! cmp -s "${TMPFILE}" "${HDFSSITE}" 2>/dev/null; then
    mv "${TMPFILE}" "${HDFSSITE}"
    chmod 664  "${HDFSSITE}"

    /etc/init.d/hadoop stop
    WAITED=0
    while kill -0 "$(< "${PIDFILE}")" 2>/dev/null; do
        sleep 1
        WAITED=$(($WAITED + 1))
        [ "${WAITED}" -gt 60 ] && break
    done
    /etc/init.d/hadoop start
fi
