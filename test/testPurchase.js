const Purchase = artifacts.require("Purchase");
const utils = require("./helpers/utils");

contract("Purchase", (accounts) => {
  let toPurchase;

  before(async () => {
    adoption = await toPurchase.deployed();
  });

  afterEach(async () => {
    await toPurchase.kill();
  });

  describe("purchasing a doge and retrieving account addresses", async () => {
    before("purchase a doge using accounts[0]", async () => {
      await toPurchase.purchase(8, { from: accounts[0] });
      expectedPurchaser = accounts[0];
    });
   
    it("can fetch the address of an owner by doge id", async () => {
      const purchaser = await toPurchase.getPßurchasers(8);
      assert.equal(purchaser, expectedPurchaser, "The owner of the purchased doge should be the first account.");
    });

    it("can fetch the collection of all doge owners' addresses", async () => {
      const purchasers = await toPurchase.getPurchasers();
      assert.equal(purchasers[8], expectedPurchaser, "The owner of the purchased doge should be in the collection.");
    });
    
//    it("should not allow discount after discount is used", async () => {
//      await utils.shouldThrow(toPurchase.purchase()); // using utils.js
//    })
  });
});