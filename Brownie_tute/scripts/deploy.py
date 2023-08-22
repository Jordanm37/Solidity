from brownie import Storage, accounts

def deploy():
    account = accounts[0]
    storage_deployment = Storage.deploy({"from": account}) #Account specified and contract instancepippip
    # print(type(Storage)) # <class 'contracts.ContractContainer'>
    # print(storage_deployment)
    # storage_deployment.store(5)
    # var = storage_deployment.retrieve() 
    print("contract deployed")
    
    
def main():
    deploy()
    