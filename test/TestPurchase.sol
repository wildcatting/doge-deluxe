pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Purchase.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TestPurchase {
 // The address of the purchase contract to be tested
 Purchase buy = Purchase(DeployedAddresses.Purchase());

 // The id of the pet that will be used for testing
 uint expectedPetId = 8;

 //The expected owner of purchased pet is this contract
 address expectedPurchaser = address(this);

 uint public initialBalance = 1 ether;

    // Testing the purchase() function because the main functionality provided by this contract is in successfully acquiring product(s) from digital marketplace.
    function testUserCanPurchasePet() public {
        uint returnedId = buy.purchase.value(1 ether)(expectedPetId);
        Assert.equal(returnedId, expectedPetId, "Purchase of the expected pet should match what is returned.");
    }

    // Testing retrieval of a single pet's owner because this information is needed to disable the purchase button on purchased pet.
    function testGetPurchaserAddressByPetId() public {
        address purchaser = buy.getPurchasers()[expectedPetId];
        Assert.equal(purchaser, expectedPurchaser, "Owner of the expected pet should be this contract");
    }

    // Testing retrieval of all pet owners because this information is needed to keep track of accumulated balances.
    function testGetPurchaserAddressByPetIdInArray() public {
        // Store adopters in memory rather than contract's storage
        address[16] memory purchasers = buy.getPurchasers();
        Assert.equal(purchasers[expectedPetId], expectedPurchaser, "Owner of the expected pet should be this contract");
    }

    // Testing admin status of contract owner because this determines whether the reset button is visible or not.
    function testIsNotAdmin() public {
        Assert.equal(buy.isAdmin(), false, "Owner of the contract should not be the admin");
    }

    // Testing availability of withdrawable funds because this determines whether the refund button is visible or not.
    function testRefundAvailable() public {
        Assert.equal(buy.refundAvailable(), false, "Owner should not have available funds to withdraw");
    }
}