#!/bin/bash

echo "!"

# SETTINGS
decredFolder="$HOME/decred"
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

printf "\033c"
echo ">>"
maxPrice=`dcrctl ${dcrctlWalletArgs} getticketmaxprice`
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
printf "\033[1;37m\033[40m $dcrversion | $balanceAll DCR | $dateNow \e[0m \n"
printf "\e[95mStatus  \e[33m=> \e[35mPoS Enabled: $stake, Wallet Unlocked: $unlocked, Ticket Max Price: $maxPrice\e[0m \n"
printf "Blockheight: %'d" $blockcount
echo ""
printf "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< \e[0m"
echo ""
printf "\e[36m	.-=[ deCRED WALLET ]=-. 			.-=[ POS TICKETS ]=-.		.-=[ NETWORK ]=-.\e[0m"
echo ""
printf "\e[36m	All:			$balanceAll 		All:			$(($immature+$live))	Hashrate:	$getnetworkhashps 	\e[0m\n"
printf "\e[31m	Locked: 		$balanceLocked		\e[32mMature:			$live	Difficulty:	$getdifficulty 		\e[0m\n"
printf "\e[1;32m 	Spendable:		$balanceSpendable		Immature:		$immature	CoinSupply	$getcoinsupply 		\e[0m\n"
printf "\e[32m	Immature All:	$imatureFunds				Done:           	$voted	Peers:		$getconnectioncount \e[0m\n"
printf "\e[1;32m	^ Coinbase: 	$balanceImmaturecoinbaserewards								\e[34mWon:            $totalsubsidy 	\e[0m\n"
printf "\e[32m	^ Stakegen: 	$balanceImmaturestakegeneration \e[0m\n"
echo ""
printf "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< \e[0m"
echo ""
printf "\e[36m 	.-=[ TICKETBUYER ]=-.			.-=[ TICKET STATISTICS ]=-."
echo ""
printf "\e[36m 	Price Now: 	$difficulty		Done:           $voted \e[0m \n"
printf "\e[32m 	Next Expected: 	$difficultyExpected		\e[34mWon:            $totalsubsidy \e[0m \n"
printf "\e[1;32m	Next Max:	$difficultyMax		\e[31mMissed:         $missed \e[0m \n"
printf "\e[32m 	Next Min:	$difficultyMin 		Missed: 		$missedc2 \e[0m  \n"
printf "\e[1;32m 	Poolsize:	$Poolsize 			Revoked:        $revoked \e[0m\n"
printf "\e[32m	AllMempool:	$allmempooltix			Expired:        $expired \e[0m\n"
printf "\e[1;32m 	OwnMempool:	$ownmempooltix			Expired:        $votec2 \e[0m\n"
printf "\e[32m	Immature:	$immature \e[0m\n"
printf "\e[1;32m 	My Fee:		$ticketFee \e[0m\n"
printf "\e[32m	My Price:	$maxPrice \e[0m\n"
printf "\e[1;32m 	AvgTicketprice: $averageticketprice \e[0m \n"
echo ""
printf "\e[36m	.-=]MEMPOOL[=-. \e[0m"
echo ""
printf "\e[32m	MemFeeMax:      $ticketfeeinfoMax\e[0m\n"
printf "\e[1;32m	MemFeeMin:      $ticketfeeinfoMin\e[0m\n"
printf "\e[32m	MemFeeMedian: 	$ticketfeeinfoMedian\e[0m\n"
echo ""
printf "\e[33m >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><\e[0m"
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

printf "\e[36m    .-=[ SOLO POS ]=-.\e[0m"
echo ""
printf "\e[1m	Current Block: 			$blockcount\e[0m"
echo "	Upcoming Reward Blocks: 	$rewardblock"
echo ""
echo "	Votes per Day:"
echo "  $votedTicketsPerDay  |"
echo ""
echo "					●▬▬▬▬๑۩۩๑▬▬▬▬▬●"
printf "	\e[36m༼ つ ◕_◕ ༽つ \e[32mSUPPORT DECRED AND JOIN A STAKEPOOL"
printf "			\e[5mhttp://pool.d3c.red			\e[36m／人 ◕‿‿◕ 人＼\e[0m"
fi


echo ""
echo " .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo."
printf "\e[1mDecred | Rethink Digital Currency.\e[0m \n"

