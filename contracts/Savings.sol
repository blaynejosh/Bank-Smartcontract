// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract Savings {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 1 * 1E18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    mapping(address => uint256) public balanceOf;

    address public owner;

    constructor(){
        owner = msg.sender;
    }
    
   

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "You need to spend more ETH!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676);
        return priceFeed.version();
    }

    modifier onlyOwner {
            require(msg.sender == owner, "You are not the owner!");
            _;
    }

    function withdraw() public payable onlyOwner {        
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this). balance}("");
        require(callSuccess, "Call failed");
    }

    function getBalance(uint256 balance) public view returns(uint256) {
        balance = balanceOf[msg.sender];

        return balance;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}