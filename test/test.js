const Trading = artifacts.require("Trading");
const Web3 = require('web3');

contract("Trading", async accounts => {
  let instance;
  let trader; 
  let contestId;

  before(async () => {
    instance = await Trading.deployed();
  });

  it("should join contest", async () => {
    let trader = await instance.joinContest(1, {from: accounts[0], value: Web3.utils.toWei('50', 'ether')});
    let wallet = await instance.getTraderWallet.call(accounts[0]);
    
    assert.equal(1000, wallet['0'].toNumber());
  });

  it("should trade currency to ethers", async () => {
    let trader = await instance.trade(100, 1, true, {from: accounts[0]});
    let wallet = await instance.getTraderWallet.call(accounts[0]);
    
    assert.equal(900, wallet['0'].toNumber());
  });

  it("should trade ethers to currency", async () => {
    let trader = await instance.trade(100, 1, false, {from: accounts[0]});
    let wallet = await instance.getTraderWallet.call(accounts[0]);
    
    assert.equal(1000, wallet['0'].toNumber());
  });

  it("should retrieve contest", async () => {
    let contest = await instance.getContest(1, {from: accounts[0]});
    
    assert.notEqual(0, contest['0'].toNumber());
  });

  it("should set end of room", async () => {
    let date = 12;
    await instance.setRoomEnd(1, date, {from: accounts[0]});
    let contest = await instance.getContest(1, {from: accounts[0]});
    
    assert.equal(date, contest['1'].toNumber());
  });

  it("should failed join room", async () => {
    let trader = await instance.joinContest(1, {from: accounts[1], value: 1});
    let wallet = await instance.getTraderWallet.call(accounts[1]);
  
    assert.equal(0, wallet['0'].toNumber());
  });

  it("should pay winner", async () => {
    let winner = await instance.getWinner(1, {from: accounts[1]});

    console.log(winner);
    

    await instance.getPrize(winner);
  
    assert.equal(0, wallet['0'].toNumber());
  });
});