#!/bin/sh
# Check if the nixpkgs revision in the latest `nixpkgs.nix` on origin/master is
# up to date with the CHANNEL.
CHANNEL="nixos-unstable"
# We use origin/master to ensure that the updates are actually committed and
# pushed. The script prints all channel revisions that are newer than the
# current system revision. This can be used to update the revision in
# nixpkgs.nix. Prints all revisions of the last month if the current system
# revision is older than that or not a channel revision. The exit code is 0 if
# an update is available, 1 if no update is available.

# Output format:
# {revision} {commit date}

# It would be nicer to use nix-shell, but that has a runtime penalty. For now
# we'll just assume that curl and coreutils are available.

# Set the current working directory to the script directory.
cd "$( dirname $0 )"

# Find the current nixpkgs revision with sed. This is hacky. It would be better
# to specify the revision in a standalone and easily machine-readable file
# instead. We check the version that is used by the latest revision of the
# origin master branch.
cur_rev="$(git show origin/master:nixpkgs.nix | sed -n 's/.*nixpkgs-rev = "\(.*\)".*;/\1/p')"

# Iterate over channel revisions, latest first.
export exit_code=1
curl --silent -L "https://channels.nix.gsc.io/$CHANNEL/history-v2" | tac | {
	while read line; do
		# Parse line from channel history
		IFS=' ' read rev commit_epoch channel_epoch <<< "$line"

		last_month_epoch="$( date --date="now - 1month" +%s )"
		if [[ "$channel_epoch" < "$last_month_epoch" ]]; then
			# Avoid processing the entire list. Go at most one month back.
			break
		fi

		# Convert the epoch to a human-readable iso date
		channel_iso="$(date --iso-8601 --date=@"$channel_epoch")"

		if [[ "$rev" == "$cur_rev" ]]; then
			break
		else
			# $rev is a potential update
			export exit_code=0
		fi
		echo "${rev} ${channel_iso}"
	done
	# Use command grouping to remember exit code set in the loop
	# http://mywiki.wooledge.org/BashFAQ/024
	exit "$exit_code"
}
