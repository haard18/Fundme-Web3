// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {helperConfig} from "./helperConfig.s.sol";
contract deployFundme is Script{
    function run() external returns(FundMe){

        //anything before startbroadcast will not be a tx
        helperConfig Helperconfig=new helperConfig();
        address ethUsdPricefeed=Helperconfig.activeNetworkConfig();
        vm.startBroadcast();
        //to remove this hard coding we will use mock contract concept
        FundMe fundme=new FundMe(ethUsdPricefeed);
        vm.stopBroadcast();
        return fundme;
    }
}