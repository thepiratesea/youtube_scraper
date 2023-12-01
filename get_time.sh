googleresponse=`echo "$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"`
googleyear=`echo $googleresponse | cut -d " " -f "4"`
googlemonth=`echo $googleresponse | cut -d " " -f "3"`
googleday=`echo $googleresponse | cut -d " " -f "2"`
googletime=`echo $googleresponse | cut -d " " -f "5"`

if [[ $googlemonth == "Jan" ]]; then
    googlemonth=01
elif [[ $googlemonth == "Feb" ]]; then
    googlemonth=02
elif [[ $googlemonth == "Mar" ]]; then
    googlemonth=03
elif [[ $googlemonth == "Apr" ]]; then
    googlemonth=04
elif [[ $googlemonth == "May" ]]; then
    googlemonth=05
elif [[ $googlemonth == "Jun" ]]; then
    googlemonth=06
elif [[ $googlemonth == "Jul" ]]; then
    googlemonth=07
elif [[ $googlemonth == "Aug" ]]; then
    googlemonth=08
elif [[ $googlemonth == "Sep" ]]; then
    googlemonth=09
elif [[ $googlemonth == "Oct" ]]; then
    googlemonth=10
elif [[ $googlemonth == "Nov" ]]; then
    googlemonth=11
elif [[ $googlemonth == "Dec" ]]; then
    googlemonth=12
fi



internettime=`echo -n "$googleyear-$googlemonth-$googleday $googletime"`
internetepochtime=$(date -d "$googlemonth/$googleday/$googleyear $googletime" +'%s')

localyear=`date +'%Y'`
localmonth=`date +'%m'`
localday=`date +'%d'`
localhour=`date +'%H'`
localminute=`date +'%M'`
localsecond=`date +'%S'`
localmachinetime=`echo -n "$localyear-$localmonth-$localday $localhour:$localminute:$localsecond"`
localmachineepochtime=$(date +%s)

if [[ $internettime == "" ]]; then
    internettime=$localmachinetime
fi

if [[ $internetepochtime == "" ]]; then
    internetepochtime=$localmachineepochtime
fi
