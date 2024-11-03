###SELECT RANDOM INVIDIOUS INSTANCE###
invidious_instances=("iv.nboeck.de" "vid.puffyan.us" "yt.artemislena.eu" "invidious.projectsegfau.lt" "invidious.private.coffee" "invidious.jing.rocks" "invidious.nerdvpn.de" "iv.ggtyler.dev" "inv.nadeko.net" "invidious.privacyredirect.com" "yt.drgnz.club" "invidious.tiekoetter.com" "yewtu.be" "invidious.flokinet.to" "invidious.slipfox.xyz" "vid.priv.au" "invidious.0011.lt" "inv.zzls.xyz" "invidious.protokolla.fi")
while :
do
    randominvidious=$(($RANDOM % 18))
    invidious=${invidious_instances[$randominvidious-1]}
    checkinvidious=$(curl -s "https://$invidious/api/v1/videos/jNQXAC9IVRw" | jq -r '.title' 2> /dev/null)
    if [[ "$checkinvidious" == "Me at the zoo" ]]; then
        echo "Using Invidious instance https://$invidious"
        break
    else
        echo "$invidious is broken...trying another"
    fi
done
