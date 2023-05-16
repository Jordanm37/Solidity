from brownie import Funding, network, config, exceptions
from scripts.reusables import get_account
import pytest

def test_deploy():
    #Arrange
    account = get_account()
    price_feed_address = config["networks"][network.show_active()]["eth_usd_pricefeed"]
    funding_contract = Funding.deploy(price_feed_address, {"from": account})
    #Act
    current_price = funding_contract.getPrice()
    #Assert
    assert current_price >= 120000000000
def test_donation():
    #Arrange
    account = get_account()
    price_feed_address = config["networks"][network.show_active()]["eth_usd_pricefeed"]
    funding_contract = Funding.deploy(price_feed_address, {"from": account})
    #Act
    amount_in_wei = funding_contract.convert(1200)
    funding_contract.donate(1200, {"from": account, "value": amount_in_wei})
    #Assert
    assert amount_in_wei <= 972530640000000000
    # with pytest.raises(exceptions.VirtualMachineError):
    #     funding_contract.donate(1200, {"from": account, "value": amount_in_wei})
