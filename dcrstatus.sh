#! /bin/sh
echo "!"

# SETTINGS
dcrwalletLogFolder="/root/.dcrwallet/logs/mainnet/"
decredFolder="/root/"



printf "\033c"
echo "?"

# CHECK CONNECTION TO RPC SERVER
dcrctl --wallet getbalance >/dev/null 2>&1
if [ $? -eq 1 ]; then
echo "CRITICAL - No connection to dcrwallet"
exit 2
fi


dateNow=`date +"%d-%b-%Y %X"`
ll=$(last -1 -R  $USER | head -1 | cut -c 20-)
lastlogin=$(echo "$ll")



printf "\033c"
echo ">"
balanceAll=`dcrctl --wallet getbalance '*' 0 all`
balanceLocked=`dcrctl --wallet getbalance '*' 0 locked`
balanceSpendable=`dcrctl --wallet getbalance '*' 0 spendable`
stakeInfo=`dcrctl --wallet getstakeinfo`

printf "\033c"
echo ">>"
maxPrice=`dcrctl --wallet getticketmaxprice`
ticketFee=`dcrctl --wallet getticketfee`
blockcount=`dcrctl getblockcount`
dcrversion=`dcrctl --version`
stakeDiff=`dcrctl --wallet estimatestakediff`
ticketfeeinfo=`dcrctl --wallet ticketfeeinfo`
imatureFunds=`awk -va=$balanceAll -vl=$balanceLocked -vs=$balanceSpendable 'BEGIN{printf "%.8f" , a-l-s}'`

printf "\033c"
echo ">>>"
all=$(dcrctl --wallet getbalance "*" 0 all)
spend=$(dcrctl --wallet getbalance default 0 spendable)
lock=$(dcrctl --wallet getbalance default 0 locked)
json=$(dcrctl --wallet getstakeinfo)
winfo=$(dcrctl --wallet walletinfo)

printf "\033c"
echo ">>>>"
ticketfeeinfoMin=$(echo "$ticketfeeinfo" | jq '.feeinfomempool.min')
ticketfeeinfoMax=$(echo "$ticketfeeinfo" | jq '.feeinfomempool.max')
ticketfeeinfoMedian=$(echo "$ticketfeeinfo" | jq '.feeinfomempool.median')

printf "\033c"
echo ">>>>>"
stake=$(echo "$winfo" | jq '.stakemining')
txfee=$(echo "$winfo" | jq '.txfee')
unlocked=$(echo "$winfo" | jq '.unlocked')
ticketfee=$(echo "$winfo" | jq '.ticketfee')

printf "\033c"
echo ">>>>>>"
totalsubsidy=$(echo "$json" | jq '.totalsubsidy')
voted=$(echo "$json" | jq '.voted')
missed=$(echo "$json" | jq '.missed')
proportionmissed=$(echo "$json" | jq '.proportionmissed')
revoked=$(echo "$json" | jq '.revoked')
difficulty=$(echo "$json" | jq '.difficulty')
poolsize=$(echo "$json" | jq '.poolsize')

printf "\033c"
echo ">>>>>>>"
difficultyMin=$(echo "$stakeDiff" | jq '.min')
difficultyMax=$(echo "$stakeDiff" | jq '.max')
difficultyExpected=$(echo "$stakeDiff" | jq '.expected')

printf "\033c"
echo ">>>>>>>"
immature=$(echo "$json" | jq '.immature')
live=$(echo "$json" | jq '.live')
ownmempooltix=$(echo "$json" | jq '.ownmempooltix')
allmempooltix=$(echo "$json" | jq '.allmempooltix')
expired=$(echo "$json" | jq '.expired')

printf "\033c"
echo ">>>>>>>>>"
votec1=$(echo "scale=2; $voted/100" | bc)
votec2=$(echo "scale=2; $expired/$votec1" | bc)
missedc1=$(echo "scale=2; $voted/100" | bc)
missedc2=$(echo "scale=2; $missed/$missedc1" | bc)

printf "\033c"
echo ">>>>>>>>>>"
getnetworkhashps=`dcrctl getnetworkhashps`
getdifficulty=`dcrctl getdifficulty`
getcoinsupply=`dcrctl getcoinsupply`
getconnectioncount=`dcrctl getconnectioncount`
# NETWORL HEALTH



printf "\033c"

echo "$dcrversion | $balanceAll DCR | $dateNow | $lastlogin"
/bin/echo -e "\e[95mStatus  \e[33m=> \e[35mPoS Enabled: $stake, Wallet Unlocked: $unlocked, Ticket Max Price: $maxPrice\e[0m"
echo "Blockheight: $blockcount"
/bin/echo -e "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< \e[0m"
echo ""
/bin/echo -e "\e[36m	.-=[ deCRED WALLET ]=-. 		.-=[ POS TICKETS ]=-.			.-=[ NETWORK ]=-."
echo ""
/bin/echo -e "\e[1m	All:		$balanceAll		All: 		$(($immature+$live))			Hashrate:	$getnetworkhashps\e[0m"
echo "	Locked: 	$balanceLocked		Mature:         $live			Difficulty:	$getdifficulty"
/bin/echo -e "\e[1m 	Spendable:	$balanceSpendable 		Immature:       $immature			CoinSupply	$getcoinsupply\e[0m"
echo "	Immature:	$imatureFunds 		Done:           $voted			Peers:		$getconnectioncount"
/bin/echo -e "\e[1m 						Won:            $totalsubsidy\e[0m"
echo ""
/bin/echo -e "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< \e[0m"
echo ""
/bin/echo -e "\e[36m 	.-=[ TICKETBUYER ]=-.			.-=[ TICKET STATISTICS ]=-."
echo ""
/bin/echo -e "\e[1m 	Price Now: 	$difficulty		Done:           $voted\e[0m"
echo "	Next Expected: 	$difficultyExpected		Won:            $totalsubsidy"
/bin/echo -e "\e[1m 	Next Max:	$difficultyMax		Missed:         $missed\e[0m"
echo "	Next Min:	$difficultyMin 		Missed %	$missedc2"
/bin/echo -e "\e[1m 	Poolsize:       $poolsize 			Revoked:        $revoked\e[0m"
echo "	AllMempool:     $allmempooltix 			Expired:        $expired"
/bin/echo -e "\e[1m 	OwnMempool: 	$ownmempooltix			Expired %       $votec2\e[0m"
echo "	Immature: 	$immature"
/bin/echo -e "	\e[1mMy Fee:         $ticketFee\e[0m"
echo "	My Price: 	$maxPrice"
echo ""
/bin/echo -e "\e[36m	.-=]MEMPOOL[=-. \e[0m"
echo ""
/bin/echo -e "\e[1m	MemFeeMax:      $ticketfeeinfoMax\e[0m"
echo "	MemFeeMin:      $ticketfeeinfoMin"
/bin/echo -e "\e[1m	MemFeeMedian: 	$ticketfeeinfoMedian\e[0m"
echo ""
/bin/echo -e "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><\e[0m"
echo ""


if [ $stake = "true" ]; then
#  SOLO STAKE LOG PARSER
	cd $dcrwalletLogFolder
	votedTicketsPerDay=`cat dcrwallet.log | grep -a 'using ticket' | grep -ao "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]" | uniq -c | tr -d '\n' | sed 's/\s\{3,\}/  |  /g'`
	rewardblock=`cat dcrwallet.log | grep -a Voted  | cut -d "(" -f2 | cut -d ")" -f1 | sed -e 's/height / /g' | tr -d "\n" |{
	  read line;
	  for i in $line; do
	  payblock="$((i +256))";
	  if [ $payblock -gt $blockcount ]; then
	  echo -n "$payblock ";
	  fi
	  done;
	  echo
	}`

/bin/echo -e "\e[36m    .-=[ SOLO POS ]=-.\e[0m"
echo ""
/bin/echo -e "\e[1m	Current Block: 			$blockcount\e[0m"
echo "	Upcoming Reward Blocks: 	$rewardblock"
echo ""
echo "	Votes per Day:"
echo "  $votedTicketsPerDay  |"
echo ""
echo "					●▬▬▬▬๑۩۩๑▬▬▬▬▬●"
/bin/echo -e "	\e[36m༼ つ ◕_◕ ༽つ \e[32mSUPPORT DECRED AND JOIN A STAKEPOOL"
/bin/echo -e "			\e[5mhttp://pool.d3c.red			\e[36m／人 ◕‿‿◕ 人＼\e[0m"
fi


echo ""
echo " .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo."
/bin/echo -e "\e[1mDecred | Rethink Digital Currency.\e[0m"

