// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./LiquidityPool.sol";
import "./Pool.sol";

contract Factory {

    LiquidityPool[] public ethPools;
    Pool[] public erc20Pools;

    function createERC20ETHPool(address _tokenAddress) public {
        LiquidityPool newPool = new LiquidityPool(_tokenAddress);
        ethPools.push(newPool);
    }

    function createERC20ERC20Pool(address _token0, address _token1, address _liquidityTrackerToken) public {
        Pool newPool = new Pool(_token0, _token1, _liquidityTrackerToken);
        erc20Pools.push(newPool);
    }
}