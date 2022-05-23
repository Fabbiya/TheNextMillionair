// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IRandomNumberGenerator{
    
    function requestRandomWords() external;
    function getRandomWord() external view returns(uint256);

}