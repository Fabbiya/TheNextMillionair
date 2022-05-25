const {
  BN, // Big Number support
  constants, // Common constants, like the zero address and largest integers
  expectEvent, // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require("@openzeppelin/test-helpers");

const NextMillionaire = artifacts.require("MOCK_NextMillionaire");

describe("NextMillionaire", () => {
  let nextMillionaire = null;
  // Creating the users
  let owner, buyer;
  before(async () => {
    nextMillionaire = await NextMillionaire.deployed();
    // Getting the signers provided by ethers
    let accounts = await web3.eth.getAccounts();
    // Creating the active wallets for use
    owner = accounts[0];
    buyer = accounts[1];
    
  });

  it("Should deploy contract", async () => {
    console.log(nextMillionaire.address);
    assert(nextMillionaire.address !== "");
  });

  //create new round
  it("Create new round - NO ADMIN", async function () {
    //Getting current round number
    prevRoundId = await nextMillionaire.getRoundNo();
    //create new round
    await expectRevert(
        nextMillionaire.newRound(1653542130,{from:buyer}),
        "Ownable: caller is not the owner"
    )
  });

  //create new round
  it("Create new round - Invalid End time for lottery", async function () {
    //Getting current round number
    prevRoundId = await nextMillionaire.getRoundNo();
    //create new round
    await expectRevert(
        nextMillionaire.newRound(1653463223), // time is less than current time
        "Invalid End time for lottery"
    )
  });

  it("Create new round", async function () {
    //Getting current round number
    prevRoundId = await nextMillionaire.getRoundNo();
    //create new round
    await nextMillionaire.newRound(1653542130);
    //get round number to check if new round created
    roundId = await nextMillionaire.getRoundNo();
    console.log("roundId", roundId.toNumber());
    //check if new round created
    assert(roundId.toNumber() === prevRoundId.toNumber() + 1);
  });

  it("send Eth to smart contract", async function () {
    this.timeout(20000);
    const prevBalance = await web3.eth.getBalance(nextMillionaire.address);

    var send1 = await web3.eth.sendTransaction({
      from: buyer,
      to: nextMillionaire.address,
      value: web3.utils.toWei("1", "ether"),
    });

    var send2 = await web3.eth.sendTransaction({
      from: owner,
      to: nextMillionaire.address,
      value: web3.utils.toWei("1", "ether"),
    });

    const balance = await web3.eth.getBalance(nextMillionaire.address);
    assert(balance > prevBalance);
  });

  //guess winner
  it("Find winner and send prize to winner address", async function () {
    this.timeout(20000);
    const prevBalance = await web3.eth.getBalance(nextMillionaire.address);
    await nextMillionaire.closeRound(2);
    winner = await nextMillionaire.guessWinner(2);
    const balance = await web3.eth.getBalance(nextMillionaire.address);
    winnerAddress = await nextMillionaire.lotteryWinner(2);
    console.log("winner",winnerAddress);
    assert(balance < prevBalance);
  });

  it("Draw winner - NO ADMIN ", async function () {
    this.timeout(20000);
    await nextMillionaire.closeRound(2);
    await expectRevert(
      nextMillionaire.guessWinner(2, { from: buyer }),
      "Ownable: caller is not the owner"
    );
  });

});
