# dcrstatus
Decred Status Dashboard in Bash. Executes various dcrctl commands to fetch informations and display them as a clear dashboard in the cli.

*Make shure you have [jq](https://stedolan.github.io/jq/download/) installed. It is recommended to install [dcrd](https://github.com/decred/dcrd) and [dcrwallet](https://github.com/decred/dcrwallet) from source and set your path variables.

![alt tag](http://d3c.red/dcrstatus1.png)


## Usage

```
$ ./dcrstatus.sh
```

## Settings

### decredFolder

Type: `Path` *to your dcrctl binary
Default: `$HOME`

### dcrctlChainArgs

Type: `Arguments` *to add on your dcrctl command that queries dcrd rpc 
Default: `` 

### dcrctlWalletArgs

Type: `Arguments` *to add on your dcrctl command that queries dcrwallet rpc, 
Default: `--wallet`

For example: 
`dcrctlWalletArgs="--wallet -C /path/to/nonstandard/wallet/dcrctl.conf"`


## Version

This version is parsing the latest output of the `getbalance` rpc command. Does not work properly with version older than dcrd 0.8.0
