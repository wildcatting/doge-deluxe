pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

// @title Pet shop manager
// @author Jun Sung Lee
// @notice Purchase available dogs from shop, apply discount when available, and refund ETH if store is reset.
// @dev All function calls are currently implemented without side effects.

contract Purchase {

    using SafeMath for uint;
    
    address[16] private _purchasers;
    mapping (address => uint) private _addressBalances;
    mapping (address => uint) private _addressRefundBalances;
    address private _admin;
    bool private _stopped = false;

    modifier stopInEmergency { require(!_stopped); _; }

    constructor() public {
        _admin = msg.sender;
    }

    // @notice Reverts all previous transactions. Transaction history prior to reset is stored in _addressRefundBalances.
    // @dev Accessible only by admin. 
    function reset() public {
        require(_admin == msg.sender);
        for (uint i = 0; i < _purchasers.length; i++) {
            address purchaser = _purchasers[i];
            if (purchaser != address(0x0)) {
                _addressRefundBalances[purchaser] = _addressRefundBalances[purchaser].add(_addressBalances[purchaser]);
                _addressBalances[purchaser] = 0;
            } 
            delete _purchasers[i];
        }
    }

    // @notice Accounts can have ETH refunded for transactions prior to reset.
    // @dev Triggers after reset. Accessible only by accounts that have spent ETH in store.
    function withdraw() public {
        // @dev Denial of Service (DoS) attack prevention (see avoiding_common_attacks.md for details)
        require(_addressRefundBalances[msg.sender] > 0);
        uint amount = _addressRefundBalances[msg.sender];
	    _addressRefundBalances[msg.sender] = 0;
	    msg.sender.transfer(amount);
    }

    // @return if msg.sender has available ETH to withdraw.
    function refundAvailable() public view returns(bool) {
        return _addressRefundBalances[msg.sender] > 0;
    }

    // @return if msg.sender is admin.
    function isAdmin() public view returns(bool) {
        return _admin == msg.sender;
    }

    // @notice Prevents purchase if UI fails to alert account that the dog of choice is no longer available.
    function circuitBreaker() public {
        _stopped = true;
    }

    // @notice Purchase available dog
    function purchase(uint petId) public payable stopInEmergency returns(uint) {
        require(petId >= 0 && petId <= 15);
        require(_purchasers[petId] == address(0x0));
        // @dev MetaMask re-entrancy attack prevention (see avoiding_common_attacks.md for details)
        if (msg.value == 0) {  
            require(eligibleDiscount() == true);
        }
        _purchasers[petId] = msg.sender;
        _addressBalances[msg.sender] = _addressBalances[msg.sender].add(msg.value);
        // @dev add msg.sender address to customer database
        return petId;
    }

    // @notice Retrieves purchasers
    function getPurchasers() public view returns(address[16] memory) {
        return _purchasers;
    }

    // @returns if account is eligible for store discount.
    function eligibleDiscount() public view returns(bool) {
        uint count = 0;
        for (uint i; i < _purchasers.length; i++) {
            if (_purchasers[i] == msg.sender) {
                count = count.add(1);
            }    
        }
        return count == 1;
    }
}
