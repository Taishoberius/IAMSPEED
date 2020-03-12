const Trading = artifacts.require("Trading");

contract("Trading", async accounts => {
  it("should create contest", async () => {
    let instance = await Trading.deployed();
    let id = await instance.createContest.call();
    console.log(uint(id));
    assert.equal(true, false);
  });
});