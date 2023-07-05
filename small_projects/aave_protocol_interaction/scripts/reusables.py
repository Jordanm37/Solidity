from brownie import accounts, network, config, interface

LOCAL_BLOCKCHAIN_ENVIRONMENTS = [
    "development",
    "ganache",
    "hardhat",
    "local-ganache",
    "mainnet-fork",
]


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    if id:
        return accounts.load(id)
    if network.show_active() in config["networks"]:
        return accounts.add(config["wallets"]["from_key"])
    return None

def get_pool():
    if network.show_active() in config["networks"]:
        provider = interface.IPoolAddressesProvider(config["networks"][network.show_active()]["pool_addresses_provider"])
        current_pool = provider.getPool()
        return current_pool
    return None

def get_weth_gateway():
    if network.show_active() in config["networks"]:
        weth_gateway = interface.IWETHGateway(config["networks"][network.show_active()]["weth_gateway_address"])
        return weth_gateway
    return None