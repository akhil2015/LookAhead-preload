#! /bin/sh
#
# preload init.d script
### BEGIN INIT INFO
# Provides:          preload
# Required-Start:    $local_fs $remote_fs $time
# Required-Stop:     $local_fs $remote_fs $time
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Adaptive readahead daemon
# Description:       Analyzes what applications users run and tries to predict
#                    what they would like to run and loads them into memory
#                    beforehand.
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/preload
NAME=preload
DESC="Adaptive readahead daemon"
DAEMON_OPTS="-s /var/lib/preload/preload.state $DAEMON_OPTS"

. /lib/lsb/init-functions

# Include preload defaults if available
if [ -f /etc/default/preload ] ; then
	. /etc/default/preload
fi

DAEMON_OPTS="$DAEMON_OPTS $OPTIONS"

test -x $DAEMON || exit 0

set -e

ret=0
case "$1" in
  start)
	log_daemon_msg "Starting $DESC" "$NAME"
	start-stop-daemon --start --quiet -u 0 $PRELOAD_IOSCHED --exec $DAEMON -- $DAEMON_OPTS || ret=$?
	if [ "$ret" = 1 ]; then
		log_progress_msg "already running"
		ret=0
	fi
	log_end_msg $ret
	;;
  stop)
	log_daemon_msg "Stopping $DESC" "$NAME"
	start-stop-daemon --stop --retry 1 --quiet -u 0 --exec $DAEMON || ret=$?
	if [ "$ret" = 1 ]; then
		log_progress_msg "not running"
		ret=0
	fi
	log_end_msg $ret
	;;
  reload|force-reload)
	log_daemon_msg "$DESC" "Reloading configuration files"
	start-stop-daemon --stop $PRELOAD_IOSCHED --signal 1 --quiet -u 0 --exec $DAEMON || ret=$?
	log_end_msg $ret
  	;;
  restart)
	log_daemon_msg "Restarting $DESC" "$NAME"
	start-stop-daemon --stop --oknodo --retry 1 --quiet -u 0 --exec $DAEMON && \
	start-stop-daemon --start --quiet -u 0 $PRELOAD_IOSCHED --exec $DAEMON -- $DAEMON_OPTS || ret=$?
	log_end_msg $ret
	;;
  status)
	status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
	;;
  *)
	N=/etc/init.d/$NAME
	log_success_msg "Usage: $N {start|stop|restart|reload|force-reload|status}" >&2
	exit 1
	;;
esac

exit 0
