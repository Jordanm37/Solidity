from brownie import Storage, accounts


def main():
    # account = accounts[0]
    # storage_deployment = Storage[-1] #gets the most recent contract 
    # storage_deployment.store(99, {'from': account})
    read()

def read():
    storage_deployment = Storage[-1]
    current_value = storage_deployment.retrieve()
    print(current_value)