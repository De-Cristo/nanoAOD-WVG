#!/bin/bash -e
SINGULARITY_OPTS=
BASE_SCRIPT="cmssw-env"
CMD_TO_RUN="/bin/bash"
#CMS_IMAGE=$(basename $0)
CMS_IMAGE="cmssw-cc7"
THISDIR=$(dirname $0)
while [ "$#" != 0 ]; do
  case "$1" in
    -h|--help)
      HELP_ARG=""
      if [ "${CMS_IMAGE}" = "${BASE_SCRIPT}" ] ; then HELP_ARG="[--cmsos <image>] "; fi
      echo "Usage: $0 [-h|--help] ${HELP_ARG}[singularity-options] [--command-to-run|-- <command to run>]"
      echo "Environment variable UNPACKED_IMAGE can be set to point to either valid docker/singularity image or unpacked image path"
      exit 0
      ;;
    --cmsos)
      if [ "${CMS_IMAGE}" != "${BASE_SCRIPT}" ] ; then
        echo "ERROR: Unknown option '--cmsos' found. This option is only valid for ${BASE_SCRIPT} command."
        exit 1
      fi
      CMS_IMAGE=$2 ; shift ; shift
      if [ $(echo "$CMS_IMAGE" | grep '/' | wc -l) -eq 0 ] ; then CMS_IMAGE="cmssw/$CMS_IMAGE"; fi
      CMS_IMAGE="$(echo ${CMS_IMAGE} | sed 's|/|-|')"
      ;;
    --command-to-run|--)
      shift
      CMD_TO_RUN="$@"
      break
      ;;
    *)
      SINGULARITY_OPTS="${SINGULARITY_OPTS} $1"
      shift
      ;;
  esac
done

MOUNT_POINTS=""
if [ "X${SINGULARITY_BINDPATH}" != "X" ] ; then MOUNT_POINTS="${SINGULARITY_BINDPATH}" ; fi
if [ -d /afs ] ; then MOUNT_POINTS="${MOUNT_POINTS},/afs" ; fi
if [ -d /cvmfs ] ; then
  for repo in cms cms-ib grid projects unpacked ; do
    ls /cvmfs/${repo}.cern.ch >/dev/null 2>&1 || true
  done
  MOUNT_POINTS="${MOUNT_POINTS},/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security/vomses:/etc/vomses,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security"
fi
for dir in /etc/tnsnames.ora /eos /build /data ; do
  if [ -e $dir ] ; then MOUNT_POINTS="${MOUNT_POINTS},${dir}" ; fi
done
OLD_CMSOS=$(echo ${SCRAM_ARCH} | cut -d_ -f1,2)
if [ -e ${THISDIR}/../cmsset_default.sh ] ; then
  CMD_TO_RUN="[ \"${OLD_CMSOS}\" != \"\$(${THISDIR}/cmsos)\" ] && export SCRAM_ARCH=""; source ${THISDIR}/../cmsset_default.sh; ${CMD_TO_RUN}"
fi

if [ "X${UNPACKED_IMAGE}" = "X" ] ;then
  if [ "${CMS_IMAGE}" = "${BASE_SCRIPT}" ] ; then
    echo "ERROR: Missing --cmsos <image> command-line argument. Usage $0 --cmsos cc7"
    exit 1
  fi
  case $CMS_IMAGE in
    cmssw-cc6) CMS_IMAGE=cmssw-slc6;;
  esac
  DOCKER_NAME="$(echo ${CMS_IMAGE} | sed 's|-|/|')"
  UNAME_M="$(uname -m)"
  if [ "${UNAME_M}" = "x86_64" ] ; then UNAME_M="${UNAME_M} amd64" ; fi
  UNPACK_DIRS="/cvmfs/unpacked.cern.ch/registry.hub.docker.com"
  for dir in ${UNPACK_DIRS} ; do
    ls ${dir} >/dev/null 2>&1 || true
    for tag in ${UNAME_M} latest ; do
      if [ -e "${dir}/${DOCKER_NAME}:${tag}" ] ; then
        UNPACKED_IMAGE="${dir}/${DOCKER_NAME}:${tag}"
        break
      fi
    done
    [ "${UNPACKED_IMAGE}" != "" ] && break
  done
  if [ "${UNPACKED_IMAGE}" = "" ] ; then
    echo "ERROR: Unable to find unpacked image '${DOCKER_NAME}' under ${UNPACK_DIRS} path(s)."
    exit 1
  fi
fi

if [ -e $UNPACKED_IMAGE ] ; then
  VALID_MOUNT_POINTS=""
  for dir in $(echo $MOUNT_POINTS | tr ',' '\n' | sort | uniq) ; do
    bind_dir=$(echo $dir | sed 's|.*:||')
    if [ -d ${UNPACKED_IMAGE}/${bind_dir} ] ; then
      VALID_MOUNT_POINTS="${VALID_MOUNT_POINTS},${dir}"
    fi
  done
  export SINGULARITY_BINDPATH=$(echo ${VALID_MOUNT_POINTS} | sed 's|^,||')
fi
export SINGULARITY_BINDPATH="${SINGULARITY_BINDPATH},/pool"
singularity -s exec ${SINGULARITY_OPTS} $UNPACKED_IMAGE sh -c "$CMD_TO_RUN"
