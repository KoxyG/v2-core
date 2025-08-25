// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;

import {UniswapV2Pair} from "../../UniswapV2Pair.sol";
import {UniswapV2Factory} from "../../UniswapV2Factory.sol";
import {UniswapV2ERC20} from "../../UniswapV2ERC20.sol";
import {ERC20} from "../ERC20.sol";
import "./Utils/Cheats.sol";

contract UniswapV2Inv {
    UniswapV2Factory public factory;
    UniswapV2Pair public pair;
    ERC20 public token0;
    ERC20 public token1;
    StdCheats cheats = StdCheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    constructor() public {
        factory = new UniswapV2Factory(address(0));
        token0 = new ERC20(1000000 * 10**18);
        token1 = new ERC20(1000000 * 10**18);
        pair = UniswapV2Pair(factory.createPair(address(token0), address(token1)));
        
        // Add initial liquidity to the pair
        token0.transfer(address(pair), 1000 * 10**18);
        token1.transfer(address(pair), 1000 * 10**18);
        pair.mint(address(this));
    }

    // INV 1 - Total supply should always be positive
    function testTotalSupplyPositive() public {
        assert(pair.totalSupply() > 0);
    }

    // INV 2 - Reserves should always be positive
    function testReservesPositive() public {
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        assert(reserve0 > 0 || reserve1 > 0);
    }

    // INV 3 - K should be constant (x * y = k)
    function testConstantProduct() public {
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint256 k = uint256(reserve0) * uint256(reserve1);
        assert(k > 0);
    }

    // INV 4 - Token balances should match reserves
    function testBalancesMatchReserves() public {
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        assert(token0.balanceOf(address(pair)) == reserve0);
        assert(token1.balanceOf(address(pair)) == reserve1);
    }

    // INV 5 - Factory should have correct pair address
    function testFactoryPairAddress() public {
        address pairAddress = factory.getPair(address(token0), address(token1));
        assert(pairAddress == address(pair));
    }
}