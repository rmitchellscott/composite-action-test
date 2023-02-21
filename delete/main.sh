#!/bin/bash
set -eo pipefail

_log() {
    local IFS=$' \n\t'
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2;
}
_abort() {
    _log "$@"
    echo 'skipped=true' >> $GITHUB_OUTPUT
    exit 0
}
prNum="$(gh pr view --json number,state -q 'select(.state=="OPEN") | .number' || true)"
if [ -z "${prNum:-}" ]; then
    _abort 'Not operating on a branch with a PR, exiting.'
fi
DESTPATH="$DESTPATH/temp$prNum"

_log Verify temp folder exists
if [ ! -d $DESTPATH ]; then
        _abort 'Correct temp folder not found, exiting.'
fi
_log Deleting temp folder
rm -rf $DESTPATH
_log "Done!"