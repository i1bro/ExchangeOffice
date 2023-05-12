// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ExchangeOffice {

    address public owner;
    mapping(IERC20 => uint256) private rates;

    constructor() {
        owner = msg.sender;
    }

    function setRate(address token, uint256 rate) public {
        require(msg.sender == owner, "Not the owner");
        rates[IERC20(token)] = rate;
    }

    function supplyToken(address token, uint256 amount) public {
        require(msg.sender == owner, "Not the owner");
        require(amount <= IERC20(token).balanceOf(msg.sender), "Not enough tokens");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function getRate(address token) public view returns(uint256) {
        return rates[IERC20(token)];
    }

    function buy(address _token, uint256 amount) public payable {
        IERC20 token = IERC20(_token);
        require(rates[token] != 0, "Token not supported");
        require(amount * rates[token] <= msg.value, "Not enough wei");
        require(amount <= token.balanceOf(address(this)), "Not enough tokens in exchange office");
        token.transfer(msg.sender, amount);
    }

    function sell(address _token, uint256 amount) public payable {
        IERC20 token = IERC20(_token);
        require(rates[token] != 0, "Token not supported");
        require(token.balanceOf(msg.sender) <= amount, "Not enough tokens");
        uint256 weiReq = amount * rates[token];
        require(weiReq <= address(this).balance, "Not enough wei in exchange office");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(weiReq);
    }

    function deleteContract() public {
        require(msg.sender == owner, "Not the owner");
        selfdestruct(payable(msg.sender));
    }
}