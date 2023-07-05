from brownie import interface
from scripts.reusables import get_account, get_pool, get_weth_gateway


account = get_account()
pool_contract = interface.IPool(get_pool())
REFERAL_CODE = 0



def main():
    # supply()
    # supply_eth()
    # borrow()
    # repay()
    withdrawal()

def supply(asset, amount, user_address):
    supply_tx = pool_contract.supply(asset, amount, user_address, REFERAL_CODE, {'from': account})
    supply_tx.wait(1)
    print('supplied succesffuly')

def supply_eth(user_address, amount):
    weth_gateway = get_weth_gateway()
    deposit_tx = weth_gateway.depositETH(get_pool(), user_address, REFERAL_CODE, {"from": account, "value": amount})
    deposit_tx.wait(1)
    print("ETH supplied successfully")

def borrow(asset_address, amount, interest_mode, user_address):
    borrow_tx = pool_contract.borrow(asset_address, amount, interest_mode, REFERAL_CODE, user_address, {'from': account})
    borrow_tx.wait(1)
    print('Borrowed DAI succesffuly')

def repay(asset_address, amount, interest_mode, borrower_address):
    repay_tx = pool_contract.repay(asset_address, amount, interest_mode, borrower_address, {'from': account})
    print(repay_tx)
    print('Repaid some  of your debts')

def withdrawal(asset_address, amount, recipient_address):
    withdrawal_tx = pool_contract.withdraw(asset_address, amount, recipient_address, {'from': account})
    withdrawal_tx.wait(1)
    print('Withdrew some of your assets')