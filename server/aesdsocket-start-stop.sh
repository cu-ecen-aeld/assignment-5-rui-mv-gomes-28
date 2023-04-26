APP=aesdsocket
case "$1" in
	start)
		echo "aesdsocket start"
		start-stop-daemon -S -n $APP -a /usr/bin/$NAME --d
		;;
	stop)
		echo "aesdsocket stop"
		start-stop-daemon -K -n $NAME
		;;
	*)
		echo "$0 {start | stop}"
		exit 1
		;;
esac
	
exit 0
