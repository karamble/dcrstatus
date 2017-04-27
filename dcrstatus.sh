#! /bin/sh
echo "!"

# SETTINGS
decredFolder="$HOME"
dcrctlChainArgs=""
dcrctlWalletArgs="--wallet"



# IF YOUR WALLET has SOLO STAKE MINING ENABLED SET YOUR LOGFILE DIRECTORY:
dcrwalletLogFolder="$HOME/.dcrwallet/logs/mainnet/"



printf "\033c"
echo "?"
# CHECK CONNECTION TO RPC SERVER
dcrctl ${dcrctlWalletArgs} getbalance >/dev/null 2>&1
if [ $? -eq 1 ]; then
echo "CRITICAL - No connection to dcrwallet"
exit 2
fi

# CHECK WALLET SYNCING
printf "\033c"
dcrctl ${dcrctlWalletArgs} getstakeinfo >/dev/null 2>&1
if [ $? -eq 1 ]; then
echo "CRITICAL - CURRENTLY SYNCING TO LATEST BLOCK - TRY AGAIN LATER"
exit 2
fi


# NEEDS FILE CHECKS IF DCRCTL IS AVAILABLE
cd $decredFolder


dateNow=`date +"%d-%b-%Y %X"`



printf "\033c"
echo ">"
balanceAll=`dcrctl ${dcrctlWalletArgs} getbalance | jq -r '[.balances[]|.total] | add'`
balanceLocked=`dcrctl ${dcrctlWalletArgs} getbalance | jq -r '[.balances[]|.lockedbytickets] | add'`
balanceSpendable=`dcrctl ${dcrctlWalletArgs} getbalance | jq -r '[.balances[]|.spendable] | add'`
balanceImmaturecoinbaserewards=`dcrctl ${dcrctlWalletArgs} getbalance | jq -r '[.balances[]|.immaturecoinbaserewards] | add'`
balanceImmaturestakegeneration=`dcrctl ${dcrctlWalletArgs} getbalance | jq -r '[.balances[]|.immaturestakegeneration] | add'`
stakeInfo=`dcrctl ${dcrctlWalletArgs} getstakeinfo`
voteChoices=$(dcrctl ${dcrctlWalletArgs} getvotechoices)

printf "\033c"
echo ">>"
ticketFee=`dcrctl ${dcrctlWalletArgs} getticketfee`
blockcount=`dcrctl ${dcrctlChainArgs} getblockcount`
dcrversion=`dcrctl ${dcrctlChainArgs} --version`
stakeDiff=`dcrctl ${dcrctlWalletArgs} estimatestakediff`
ticketfeeinfo=`dcrctl ${dcrctlWalletArgs} ticketfeeinfo`
imatureFunds=`awk -va=$balanceAll -vl=$balanceLocked -vs=$balanceSpendable 'BEGIN{printf "%.8f" , a-l-s}'`

printf "\033c"
echo ">>>"
json=$(dcrctl ${dcrctlWalletArgs} getstakeinfo)
winfo=$(dcrctl ${dcrctlWalletArgs} walletinfo)

printf "\033c"
echo ">>>>"
ticketfeeinfoMin=$(echo "$ticketfeeinfo" | jq '.feeinfomempool.min')
ticketfeeinfoMax=$(echo "$ticketfeeinfo" | jq '.feeinfomempool.max')
ticketfeeinfoMedian=$(echo "$ticketfeeinfo" | jq '.feeinfomempool.median')
averageticketprice=$(echo "scale=6;`dcrctl getticketpoolvalue|sed -e 's/[eE]+*/\*10\^/'`/`dcrctl --wallet getstakeinfo|jq .poolsize`"|bc)

printf "\033c"
echo ">>>>>"
stake=$(echo "$winfo" | jq '.voting')
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

printf "\033c"
echo ">>>>>>>>>>"
voteVersion=$(echo "$voteChoices" | jq '.version')
choiceCounter=$(echo "$voteChoices" | jq '.choices | length')


printf "\033c"

echo "$dcrversion | $balanceAll DCR | $dateNow"
/bin/echo -e "\e[95mStatus  \e[33m=> \e[35mPoS Enabled: $stake, Wallet Unlocked: $unlocked\e[0m"
echo "Blockheight: $blockcount"
/bin/echo -e "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< \e[0m"
echo ""
/bin/echo -e "\e[36m	.-=[ deCRED WALLET ]=-. 		.-=[ POS TICKETS ]=-.			.-=[ NETWORK ]=-."
echo ""
/bin/echo -e "\e[1m	All:		$balanceAll 		All: 		$(($immature+$live))			Hashrate:	$getnetworkhashps\e[0m"
echo "	Locked: 	$balanceLocked		Mature:         $live			Difficulty:	$getdifficulty"
/bin/echo -e "\e[1m 	Spendable:	$balanceSpendable 		Immature:       $immature			CoinSupply	$getcoinsupply\e[0m"
echo "	Immature All:	$imatureFunds 		Done:           $voted			Peers:		$getconnectioncount"
/bin/echo -e "\e[1m	^ Coinbase: 	$balanceImmaturecoinbaserewards			Won:            $totalsubsidy\e[0m"
echo "	^ Stakegen: 	$balanceImmaturestakegeneration"
echo ""
/bin/echo -e "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< \e[0m"
echo ""
/bin/echo -e "\e[36m 	.-=[ TICKETBUYER ]=-.			.-=[ TICKET STATISTICS ]=-.		.-=]MEMPOOL[=-."
echo ""
/bin/echo -e "\e[1m 	Price Now: 	$difficulty		Done:           $voted			 MemFeeMax:      $ticketfeeinfoMax\e[0m"
echo "	Next Expected: 	$difficultyExpected		Won:            $totalsubsidy		 MemFeeMin:      $ticketfeeinfoMin"
/bin/echo -e "\e[1m 	Next Max:	$difficultyMax		Missed:         $missed			MemFeeMedian:   $ticketfeeinfoMedian\e[0m"
echo "	Next Min:	$difficultyMin 		Missed %	$missedc2"
/bin/echo -e "\e[1m 	Poolsize:       $poolsize 			Revoked:        $revoked\e[0m"
echo "	AllMempool:     $allmempooltix 			Expired:        $expired"
/bin/echo -e "\e[1m 	OwnMempool: 	$ownmempooltix			Expired %       $votec2\e[0m"
echo "	Immature: 	$immature"
/bin/echo -e "	\e[1mMy Fee:         $ticketFee\e[0m"
/bin/echo -e "	\e[1mAvgTicketprice: $averageticketprice\e[0m"
echo ""
/bin/echo -e "\e[36m	.-=[ AGENDAS & VOTING ]=-. \e[0m"
echo ""
/bin/echo -e "\e[1m	Version:      	v$voteVersion\e[0m"
echo "	Agendas:	$choiceCounter"
echo ""
/bin/echo -e "\e[36m	.-=[ YOUR CHOICES ]=-. \e[0m"
echo ""
count=$(($choiceCounter-1))
for i in `seq 0 $count`;
do
/bin/echo -e "\e[33m	.oOo.oOo.oOo.oOo.oOo.oOo.oOo.\e[0m"
/bin/echo -n "	AgendaID:	"
/bin/echo "$voteChoices" | jq -r ".choices[$i].agendaid"
/bin/echo -n "	Description:	"
/bin/echo "$voteChoices" | jq -r ".choices[$i].agendadescription"
/bin/echo -n "	Choice:		"
/bin/echo "$voteChoices" | jq -r ".choices[$i].choiceid"
/bin/echo -n "	ChoiceDesc:	"
/bin/echo "$voteChoices" | jq -r ".choices[$i].choicedescription"
done
echo ""
/bin/echo -e "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><\e[0m"
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
echo ""
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
/bin/echo -e "			\e[5mhttps://pool.d3c.red			\e[36m／人 ◕‿‿◕ 人＼\e[0m"
fi
echo ""
/bin/echo -e "\e[36m	Decred | Rethink Digital Currency.\e[0m"
echo ""
