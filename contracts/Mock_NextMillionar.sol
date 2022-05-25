// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
//This contract is for test purpose only... 
//chainlink VRF random number hardcoded in the code

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IrandomNumberGenerator.sol";

contract MOCK_NextMillionaire is Ownable {
    enum Status {
        Open, // The lottery is open for ticket purchases
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

    //store the random number generated from chainlink
    IRandomNumberGenerator internal randomGenerator_;

    //----------------------------------EVENTS-----------------------------
    //Open New Round
    event NewRoundOpen(uint256 lotteryId);
    event Received(address, uint256);
    event PrizeSent(address, uint256);

    //------------------------------CONSTRUCTOR----------------------------------
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
    function newRound(uint256 _closingTimestamp)
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
        //add new round to all lottery rounds
        allLotteries_[lotteryId] = newLottery;
        //reset counter for contributors in new round 
        contributorCounter_=0;
        // Emitting important information around new lottery.
        emit NewRoundOpen(lotteryId);
    }

    //Register with paying 1 Eth
    // send Eth to the contract address
    receive() external payable {
        uint256 min = 1 ether;
        require(
            msg.value == min,
            "Your contribution should be exactly 1 ETHER"
        );
        require(
            allLotteries_[lotteryIdCounter_].closingTimestamp >= block.timestamp,
            "This round is closed!"
        );
        contributorCounter_ += 1;
        contributors_[contributorCounter_] = msg.sender;
        emit Received(msg.sender, msg.value);
    }

    //Guess Winner by admin
    function guessWinner(uint256 _lotteryId) external onlyOwner {
        // Checks that the lottery is past the closing block
        require(
            allLotteries_[_lotteryId].closingTimestamp <= block.timestamp,
            "Cannot set draw winner during lottery"
        );
        // Checks lottery numbers have not already been drawn
        require(
            allLotteries_[_lotteryId].lotteryStatus == Status.Open,
            "Lottery State incorrect for draw"
        );
        require(contributorCounter_ > 0 , "There is no participants in this round");
        //get random number from chainlink from numbers for participates
        uint256 no = getRand();
        address winner = contributors_[no];
        allLotteries_[lotteryIdCounter_].winnerList = winner;
        allLotteries_[lotteryIdCounter_].lotteryStatus = Status.Completed;
        //reset contributors counter 
        contributorCounter_ = 0;
        
        //transfer all balance amount to winner
        uint256 amount = address(this).balance;
        Address.sendValue(payable(winner), amount);
        emit PrizeSent(winner, amount);
    }

    //track of lottery winner
    function lotteryWinner(uint256 round) external view returns (address) {
        return allLotteries_[round].winnerList;
    }

    function getRand() internal view returns(uint256) {
        
        uint256 rw = 34480427320062457420864927216006904319934124299411792569154377552789426268675;
        uint256 rand = uint256(keccak256(abi.encodePacked(rw,block.timestamp,lotteryIdCounter_))) % (contributorCounter_ + 1);
        if(rand ==0){
            rw +=1 * 10**18;
            rand = uint256(keccak256(abi.encodePacked(rw,block.timestamp,lotteryIdCounter_))) % (contributorCounter_ + 1);
        }
        return rand;
    }

    function lotterySize() external view returns(uint256){
        return address(this).balance;
    }

    function getRoundNo() external view returns(uint256){
        return lotteryIdCounter_;
    }

    function getContributorsCount() external view returns(uint256){
        return contributorCounter_;
    } 

    function closeRound(uint256 roundId) external onlyOwner() {
        allLotteries_[roundId].closingTimestamp = block.timestamp;
    }
}
