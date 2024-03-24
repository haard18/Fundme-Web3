// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {deployFundme} from "../../script/deployFundme.s.sol";
contract FundmeTest is Test{
    FundMe fundme;
    uint256 constant SEND_VALUE=1 ether;
    uint256 constant STARTING_BALANCE=10 ether;
    address USER=makeAddr("user");
    

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        _;
    }
    function setUp() external{
        // fundme=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundme deployfundme=new deployFundme();
        fundme=deployfundme.run();
        vm.deal(USER,STARTING_BALANCE);
    }
    function testMinimumUsdIsFive() view public{
        assertEq(fundme.MINIMUM_USD(),5e18);
        console.log(fundme.MINIMUM_USD());
    }
    function testOwnerIsMsgSender() view public{
        // console.log(fundme.i_owner());
        // console.log(msg.sender);
        assertEq(fundme.getOwner(),msg.sender);
    }

    function testPriceConversionIsAcc() view public{
        uint256 version=fundme.getVersion();
        assertEq(version,4);
    }

    function testFundFailsLessEth() public{
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdatesFundedDS() public{
        

        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        uint256 amountFunded=fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        address funder=fundme.getFunder(0);
        assertEq(USER,funder);
    }
    function testOnlyOwnerWithdraw() public{
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }
    function testWithdrawWithSingleUser() public funded{
        //Arrange
        uint256 startingOwnerBalance=fundme.getOwner().balance;
        uint256 startingFundmeBalance=address(fundme).balance;
        //Act
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        //Assert
        uint256 endingOwnerBalance=fundme.getOwner().balance;
        uint256 endingFundmeBalance=address(fundme).balance;
        assertEq(endingFundmeBalance,0);
        assertEq(endingOwnerBalance,startingFundmeBalance+startingOwnerBalance);
    }

    function testWithdrawWithMultipleUser() public funded{
        //Arrange
        uint160 noOfFunders=10;
        uint160 startIndex=1;
        for(uint160 i=startIndex;i<noOfFunders;i++){
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }
        //Act
        uint256 startingOwnerBalance=fundme.getOwner().balance;
        uint256 startingFundmeBalance=address(fundme).balance;
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();
        //Assert
        assert(address(fundme).balance==0);
        console.log(fundme.getOwner().balance);
        assert(fundme.getOwner().balance==startingFundmeBalance+startingOwnerBalance);
    }
    function testCheaperWithdrawWithMultipleUser() public funded{
        //Arrange
        uint160 noOfFunders=10;
        uint160 startIndex=1;
        for(uint160 i=startIndex;i<noOfFunders;i++){
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }
        //Act
        uint256 startingOwnerBalance=fundme.getOwner().balance;
        uint256 startingFundmeBalance=address(fundme).balance;
        vm.startPrank(fundme.getOwner());
        fundme.cheaperWithdraw();
        vm.stopPrank();
        //Assert
        assert(address(fundme).balance==0);
        console.log(fundme.getOwner().balance);
        assert(fundme.getOwner().balance==startingFundmeBalance+startingOwnerBalance);
    }


    //Types of tests to work with address outside our environment
    // 1.Unit: Testing a specific part of the code
    // 2.Integration: Testing how our code works with the other parts of code
    // 3.Forked: Testing on a simulated real environment
    // 4.Staging : Testing our code in real environment that is not prod
}