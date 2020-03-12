const Trading = artifacts.require("Trading");

contract("Trading", async accounts => {
  it("should create contest", async () => {
    let instance = await Trading.deployed();
    let balance = await instance.createContest().call();
    assert.equal(true, false);
  });
});