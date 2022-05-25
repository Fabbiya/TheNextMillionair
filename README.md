This project will create a lottery 
users can participate with transfering 1 ETH to the contract

Admin can draw winner after the closing time is over 
The Random generated number from chainlink is used to have a randomgenerated number to select the winner so we make sure the winner will be selected randomly! 
after that, the balance of contract will be transfered to the winner address

Admin also can start new round by calling newRound function and providing closing time


NETWORK : RINKEBY

rinkeby: {
      provider: function() { 
       return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/b35d769b8321433bbac9ad5e782ff344");
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
  }


NextMillionair contract address on Rinkeby:
0x1320AA2AE6955BC6FFbaAA174948EfD40C57deD4

Random Number Generator Contract Address : 0x2aE395472B0cf014AFdd9791C198A43A4029821F

MOCK_NextMillionaire is a contract exactly the same as NextMillionair for testing purpose. The only difference is that the random number generated from chainlink is hardcoded in the contract so that we can test it on local network test

1_init_migration.js is used for deployment on Rinkeby
2_init_migration.js is used for deployment on Truffle test

you can also find test case in folser test


