# Avoiding Common Attacks

Here are two loopholes discovered while testing and addressed in the smart contract.

### MetaMask Re-Entrancy

Upon testing, it was discovered that a customer could load up pending transactions on MetaMask. After buying the first dog, an account could then hack the get-one-free discount by loading up the remaining available dogs in the cart. By loading up these pending transactions, the account could get every remaining dog in the store for free. This bug was addressed by adding an extra check in the purchase function verifying whether an account is still eligible for the discount, since a single transaction in MetaMask changes the contract state.
```
function purchase(uint petId) public payable stopInEmergency returns(uint) {
        require(petId >= 0 && petId <= 15);
        require(_purchasers[petId] == address(0x0));
        // @dev MetaMask re-entrancy attack prevention
        if (msg.value == 0) {  
            require(eligibleDiscount() == true);
        }
        _purchasers[petId] = msg.sender;
        _addressBalances[msg.sender] = _addressBalances[msg.sender].add(msg.value);
        // @dev add msg.sender address to customer database
        return petId;
    }
```

Even if the hack was discovered and a customer loaded up their MetaMask cart with multiple doges, a single purchase would increase the msg.value count. Therefore, checking if msg.value == 0 before every purchase prevented the discount from being applied to all other pending transactions.  


### Denial of Service (DoS)

Initially, the reset function reverted all purchases and returned accumulated balances to every account that had transacted with the store. 
```
function reset() public {
    require(_admin == msg.sender);
    uint amount = _addressRefundBalances[msg.sender];
    _addressRefundBalances[msg.sender] = 0;
    msg.sender.transfer(amount);
    for (uint i = 0; i < _purchasers.length; i++) {
        address purchaser = _purchasers[i];
        if (purchaser != address(0x0)) {
            _addressRefundBalances[purchaser] = _addressRefundBalances[purchaser].add(_addressBalances[purchaser]);
            _addressBalances[purchaser] = 0;
        } 
        delete _purchasers[i];
    }
}
```
However, this was vulnerable to a DoS attack in which a single external transfer call throwing would: 
1. Prevent the admin from being able to reset the store and 
2. Keep all accounts from receiving their accumulated balances. 
In order to address this vulnerability, the pull over push pattern was implemented by separating the withdraw functionality into its own function.
```
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

function withdraw() public {
    // @dev Denial of Service (DoS) attack prevention
    require(_addressRefundBalances[msg.sender] > 0);
    uint amount = _addressRefundBalances[msg.sender];
    _addressRefundBalances[msg.sender] = 0;
    msg.sender.transfer(amount);
}
```