from brownie import TokenPool, DEXToken
from scripts.reusables import get_account
from web3 import Web3


dai_address = "0x360eD9c935A0832ADdEAC6B1D2694Dea3639356B"
gst_address = "0x2d157bD2Ad24ecF5e93EAb526791FCCCB5e8F3d1"
initial_supply = Web3.toWei(1000000, "ether")


def deploy_pool():
    account = get_account()
    dex_token = DEXToken.deploy(initial_supply, {"from": account})
    pool = TokenPool.deploy(dex_token.address, {"from": account})
    tx = dex_token.transfer(pool.address, dex_token.totalSupply())
    tx.wait(1)

    balance = dex_token.balanceOf(pool.address)
    print(balance)


def main():
    deploy_pool()