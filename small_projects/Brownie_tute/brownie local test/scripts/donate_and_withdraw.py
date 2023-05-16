from brownie import Contract
from scripts.reusables import get_account

ABI = [{"inputs": [{"internalType": "address", "name": "_priceFeedAddress", "type": "address"}], "stateMutability": "nonpayable", "type": "constructor", "name": "constructor"}, {"inputs": [{"internalType": "uint256", "name": "_amount", "type": "uint256"}], "name": "convert", "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"internalType": "uint256", "name": "usdAmount", "type": "uint256"}], "name": "donate", "outputs": [], "stateMutability": "payable", "type": "function"}, {"inputs": [{"internalType": "address", "name": "", "type": "address"}], "name": "funders", "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}], "stateMutability": "view", "type": "function"}, {"inputs": [], "name": "getPrice", "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}], "stateMutability": "view", "type": "function"}, {"inputs": [], "name": "owner", "outputs": [{"internalType": "address", "name": "", "type": "address"}], "stateMutability": "view", "type": "function"}, {"inputs": [], "name": "withdraw", "outputs": [], "stateMutability": "payable", "type": "function"}]


def donate(amount):
    funding_contract = Contract.from_abi("Funding", "0x271eeF818C84f592c105008a983F2208e24bbAc7", ABI)
    print(funding_contract)
    account = get_account()
    amount_in_wei = funding_contract.convert(amount)
    print(f"The donation amount is $ {amount} which is {amount_in_wei} WEI")
    print("Funding....")
    funding_contract.donate(amount, {"from": account, "value": amount_in_wei})


def withdraw():
    funding_contract = Contract.from_abi("Funding", "0x271eeF818C84f592c105008a983F2208e24bbAc7", ABI)
    account = get_account()
    funding_contract.withdraw({"from": account})


def main():
    donate(300)
    withdraw()