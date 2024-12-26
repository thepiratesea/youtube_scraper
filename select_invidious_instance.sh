#!/bin/bash
###SELECT RANDOM INVIDIOUS INSTANCE###
invidious_instances=("iv.nboeck.de" "vid.puffyan.us" "yt.artemislena.eu" "invidious.projectsegfau.lt" "invidious.private.coffee" "invidious.jing.rocks" "invidious.nerdvpn.de" "iv.ggtyler.dev" "inv.nadeko.net" "invidious.privacyredirect.com" "yt.drgnz.club" "invidious.tiekoetter.com" "yewtu.be" "invidious.flokinet.to" "invidious.slipfox.xyz" "vid.priv.au" "invidious.0011.lt" "inv.zzls.xyz" "invidious.protokolla.fi" "invidious.adminforge.de" "invidious.yourdevice.ch" "invidious.reallyaweso.me" "invidious.materialio.us" "invidious.privacydev.net" "invidious.perennialte.ch" "invidious.einfachzocken.eu" "inv.tux.pizza")
echo ""
invidiousattempt=1
while :
do
    randominvidious=$(($RANDOM % 26))
    invidious=${invidious_instances[$randominvidious-1]}
    checkinvidious=$(curl -m 3 -s "https://$invidious/api/v1/videos/jNQXAC9IVRw" | jq -r '.title' 2> /dev/null)
    if [[ "$checkinvidious" == "Me at the zoo" ]]; then
        invidiousactive=true
        echo "Using Invidious instance https://$invidious"
        break
    else
        echo "$invidious is broken (responded with '$checkinvidious')...trying another [attempt #$invidiousattempt]"
    fi
    invidiousattempt=$(($invidiousattempt + 1))
    if [[ "$invidiousattempt" == "100" ]]; then
        invidiousactive=false
        echo "Invidious doesn't seem to be working right now. Some features will not function properly"
        break 
    fi
done
