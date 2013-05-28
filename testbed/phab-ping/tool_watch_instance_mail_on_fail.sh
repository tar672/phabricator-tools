set -e

if [ ! "$#" = "3" ]; then
    echo "usage: $0 phabricator-address from-email to-email"
    exit 2
fi

address=$1
from_email=$2
to_email=$3

# uncomment to use catchmail
#sendmail="--sendmail-binary catchmail --sendmail-type catchmail"
sendmail="--sendmail-binary sendmail --sendmail-type sendmail"

maily="../arcyd/maily --sender $from_email --to $to_email $sendmail"
$maily --subject "started pinging $address" --message " "
tempfile=`mktemp`
echo "pinging $address"
set +e

../../bin/phab-ping $address > $tempfile
result=`(head -n 20; echo === snip ===;tail -n 20) < $tempfile`
rm $tempfile
if [ "$?" = "1" ]; then
    $maily --subject "failed pinging $address" --message "$result"
    echo "$result"
    echo FAILED
    exit 1
else
    $maily --subject "stopped pinging $address" --message "$result"
    echo "$result"
    echo STOPPED
fi
