// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/Mockv3aggregator.sol";
contract helperConfig is Script{
    uint8 public constant DECIMALS=8;
    int256 public constant INITIAL_PRICE=2000e8;
    constructor(){
        if(block.chainid==11155111){
            activeNetworkConfig=getSepoliaEthConfig();
        }else{
            activeNetworkConfig=getorCreateAnvilEthConfig();
        }
    }
    struct networkConfig{
        address pricefeed;
    }
    networkConfig public activeNetworkConfig;

    function getSepoliaEthConfig() public pure returns(networkConfig memory){
        networkConfig memory sepoliaConfig=networkConfig({
            pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;   
    }

    function getorCreateAnvilEthConfig() public returns(networkConfig memory){
        if(activeNetworkConfig.pricefeed!=address(0)){
            return activeNetworkConfig;
        }


        vm.startBroadcast();
        MockV3Aggregator mockpricefeed=new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        networkConfig memory anvilconfig=networkConfig({pricefeed:address(mockpricefeed)});
        return anvilconfig;
    }
}



//deploy mocks on anvil local chain

//keep track of contract address across different chains