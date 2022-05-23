// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IrandomNumberGenerator.sol";

contract NextMillionaire is Ownable {
    enum Status {
        NotStarted, // The lottery has not started yet
        Open, // The lottery is open for ticket purchases
        Closed, // The lottery is no longer open for ticket purchases
        Completed // The lottery has been closed and the numbers drawn
    }
    struct Info {
        uint256 lotteryID; // ID for round
        Status lotteryStatus; // Status of round
        uint256 totalPrize; // The total amount of prize
        uint256 startingTimestamp; // Block timestamp for star of lottery
        uint256 closingTimestamp; // Block timestamp for end of entries
        address winnerList;
    }
    // Lottery ID's to info
    mapping(uint256 => Info) internal allLotteries_;
    // Counter for lottery IDs
    uint256 private lotteryIdCounter_;
    //contibutor counter
    uint256 private contributorCounter_;

    //contributors in each round
    mapping(uint256 => address) internal contributors_;

    IRandomNumberGenerator randomGenerator;

    //--------------------------------------EVENTS-----------------------------
    //Open New Round
    event NewRoundOpen(uint256 lotteryId);
    event Received(address, uint256);
    event PrizeSent(address, uint256);

    constructor(uint256 _closingTimestamp) {
        lotteryIdCounter_ += 1;
        Status lotteryStatus;
        lotteryStatus = Status.Open;

        // Saving data in struct
        Info memory newLottery = Info(
            lotteryIdCounter_,
            lotteryStatus,
            0,
            block.timestamp,
            _closingTimestamp,
            address(0)
        );
        allLotteries_[lotteryIdCounter_] = newLottery;

        // Emitting important information around new lottery.
        emit NewRoundOpen(lotteryIdCounter_);
    }

    //admin start lottery
    function NewRound(uint256 _closingTimestamp)
        external
        onlyOwner
        returns (uint256 lotteryId)
    {
        require(
            _closingTimestamp != 0 && _closingTimestamp > block.timestamp,
            "Invalid End time for lottery"
        );
        // Incrementing lottery ID
        lotteryIdCounter_ += 1;
        lotteryId = lotteryIdCounter_;

        Status lotteryStatus;
        lotteryStatus = Status.Open;

        // Saving data in struct
        Info memory newLottery = Info(
            lotteryId,
            lotteryStatus,
            0,
            block.timestamp,
            _closingTimestamp,
            address(0)
        );
        allLotteries_[lotteryId] = newLottery;

        // Emitting important information around new lottery.
        emit NewRoundOpen(lotteryId);
    }

    //Register with paying 1 Eth
    // send Eth to the contract address
    receive() external payable {
        uint256 min = 1 ether;
        //check msg value
        require(
            msg.value >= min,
            "Your contribution is less than Minimum amount"
        );
        contributorCounter_ + 1;
        contributors_[contributorCounter_] = msg.sender;
        emit Received(msg.sender, msg.value);
    }

    //Guess Winner by admin
    function GuessWinner() external onlyOwner {
        //get random number from chainlink from numbers for participates
        address winner = contributors_[getRandomNumber()];
        allLotteries_[lotteryIdCounter_].winnerList = winner;
        //transfer all amount to winner
        Address.sendValue(payable(winner), address(this).balance);
        emit PrizeSent(winner, address(this).balance);
    }

    //track of lottery winner
    function LotteryWinners(uint256 round) external view returns (address) {
        return allLotteries_[round].winnerList;
    }

    function getRandomNumber() internal returns (uint256) {
        randomGenerator = IRandomNumberGenerator(
            0x2aE395472B0cf014AFdd9791C198A43A4029821F
        );

        uint256 rw = randomGenerator.getRandomWord();
        return uint256(keccak256(abi.encodePacked(rw))) % contributorCounter_;
    }
}
