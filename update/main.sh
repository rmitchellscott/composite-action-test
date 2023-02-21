#!/bin/bash
set -eo pipefail
# Set up some variables so we can reference the GitHub Action context
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_log() {
    local IFS=$' \n\t'
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2;
}

TAGS=( $TAGS "$@" )
TAGS+=( $(env | grep '^YAMPL_.*' | cut -d= -f1 | cut -d_ -f2- ))
YAMPLARGS=()
DESTPATH="$DESTPATH/temp$PR_NUMBER"
YAMPL_namespace="$YAMPL_namespace-temp$PR_NUMBER"

# Copy template files to the new location
mkdir -p $DESTPATH
cp -r $TEMPLATEPATH/* $DESTPATH
# Do the YAMPL 
_log "Templating with YAMPL..."
for tag in "${TAGS[@]}"; do
        a="YAMPL_$tag"
        case ${!a} in
            RAND*)
                length=$(echo "${!a}" | sed 's/RAND//')
                YAMPLARGS+=("-v $tag=$(openssl rand -base64 32 | tr -d /=+ | cut -c -$length)")
                ;;
            COLORANIMAL)
                friendlyName=$(shuf -n 1 "$__dir/colors.txt")-$(shuf -n 1 "$__dir/animals.txt")
                YAMPLARGS+=("-v $tag=$friendlyName")
                ;;
            *)
                YAMPLARGS+=("-v $tag=${!a}")
                ;;
        esac
done
yampl -i ${YAMPLARGS[@]} $DESTPATH/*.yaml $DESTPATH/*/*.yaml
_log "Done!"