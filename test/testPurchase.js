const Purchase = artifacts.require("Purchase");

contract("Purchase", (accounts) => {
  let toPurchase;
  let expectedDogeId;

  before(async () => {
    adoption = await Purchase.deployed();
  });

  afterEach(async () => {
    await contractInstance.kill();
  });

  describe("purchasing a doge and retrieving account addresses", async () => {
    before("purchase a doge using accounts[0]", async () => {
      await toPurchase.purchase(8, { from: accounts[0] });
      expectedPurchaser = accounts[0];
    });
   
    it("can fetch the address of an owner by doge id", async () => {
      const purchaser = await toPurchase.purchasers(8);
      assert.equal(purchaser, expectedPurchaser, "The owner of the purchased doge should be the first account.");
    });

    it("can fetch the collection of all doge owners' addresses", async () => {
      const purchasers = await toPurchase.getPurchasers();
      assert.equal(purchasers[8], expectedPurchaser, "The owner of the purchased doge should be in the collection.");
     });
   });
 });