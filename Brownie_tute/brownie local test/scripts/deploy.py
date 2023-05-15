from brownie import Funding, config, network
# from brownie.network import priority_fee
from scripts.reusables import get_account

# priority_fee("4 gwei")

def main():
    account = get_account()
    print(account)
    price_feed_address = config["networks"][network.show_active()]["eth_usd_pricefeed"]
    print(price_feed_address)
    funding_contract = Funding.deploy(price_feed_address, {"from": account})
    print(funding_contract.getPrice())

