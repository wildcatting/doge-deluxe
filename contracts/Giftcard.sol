// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

contract Giftcard {
  
  // struct Winner {
  //   string proof;
  //   uint code;
  // }

  //  Winner[] public winners;
  address[10] public winners;

  // Choosing a gift 
  function chooseGift(uint giftId) public returns (uint) {
    require(giftId >= 0 && giftId <= 9);
    winners[giftId] = msg.sender;
    return giftId;
  }

  // Retrieving the giftcard winners
  function getWinners() public view returns (address[10] memory) {
    return winners;
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Source code with comments available at https://docs.soliditylang.org/en/latest/contracts.html

// contract OwnedToken {
//     // `TokenCreator` is a contract type that is defined below.
//     // It is fine to reference it as long as it is not used to create a new contract.
//     TokenCreator creator;
//     address owner;
//     bytes32 name;

//     // This is the constructor which registers the creator and the assigned name.
//     constructor(bytes32 _name) {
//         // State variables are accessed via their name and not via e.g. `this.owner`. 
//         // Functions can fbe accessed directly or through `this.f`, but the latter provides an 
//         // external view to the function. Especially in the constructor, you should not access 
//         // functions externally, because the function does not exist yet.
//         // See the next section for details.
//         owner = msg.sender;

//         // We perform an explicit type conversion from `address` to `TokenCreator` and assume that
//         // the type of the calling contract is `TokenCreator`, there is no real way to verify that.
//         // This does not create a new contract.
//         creator = TokenCreator(msg.sender);
//         name = _name;
//     }

//     function changeName(bytes32 newName) public {
//         // Only the creator can alter the name. We compare the contract based on its address which 
//         // can be retrieved by explicit conversion to address.
//         if (msg.sender == address(creator))
//             name = newName;
//     }

//     function transfer(address newOwner) public {
//         // Only the current owner can transfer the token.
//         if (msg.sender != owner) return;

//         // We ask the creator contract if the transfer should proceed by using a function of the
//         // `TokenCreator` contract defined below. If the call fails (e.g. due to out-of-gas), the
//         // execution also fails here.
//         if (creator.isTokenTransferOK(owner, newOwner))
//             owner = newOwner;
//     }
// }


// contract TokenCreator {
//     function createToken(bytes32 name)
//         public
//         returns (OwnedToken tokenAddress)
//     {
//         // Create a new `Token` contract and return its address.
//         // From the JavaScript side, the return type of this function is `address`, as this is
//         // the closest type available in the ABI.
//         return new OwnedToken(name);
//     }

//     function changeName(OwnedToken tokenAddress, bytes32 name) public {
//         // Again, the external type of `tokenAddress` is simply `address`.
//         tokenAddress.changeName(name);
//     }

//     // Perform checks to determine if transferring a token to the `OwnedToken` contract should proceed
//     function isTokenTransferOK(address currentOwner, address newOwner)
//         public
//         pure
//         returns (bool ok)
//     {
//         // Check an arbitrary condition to see if transfer should proceed
//         return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
//     }
// }



// //////////////////////////////////////////////////////////////////////////////////////////////////////////

// contract owned {
//     constructor() { owner = msg.sender; }
//     address payable owner;

//     // This contract only defines a modifier but does not use it: it will be used in derived contracts.
//     // The function body is inserted where the special symbol `_;` in the definition of a modifier appears.
//     // This means that if the owner calls this function, the function is executed and otherwise, an exception
//     // is thrown.
//     modifier onlyOwner {
//         require(
//             msg.sender == owner,
//             "Only owner can call this function."
//         );
//         _;
//     }
// }

// contract destructible is owned {
//     // This contract inherits the `onlyOwner` modifier from `owned` and applies it to the `destroy` function,
//     // which causes that calls to `destroy` only have an effect if they are made by the stored owner.
//     function destroy() public onlyOwner {
//         selfdestruct(owner);
//     }
// }

// contract priced {
//     // Modifiers can receive arguments:
//     modifier costs(uint price) {
//         if (msg.value >= price) {
//             _;
//         }
//     }
// }

// contract Register is priced, destructible {
//     mapping (address => bool) registeredAddresses;
//     uint price;

//     constructor(uint initialPrice) { price = initialPrice; }

//     // It is important to also provide the `payable` keyword here, otherwise the function will
//     // automatically reject all Ether sent to it.
//     function register() public payable costs(price) {
//         registeredAddresses[msg.sender] = true;
//     }

//     function changePrice(uint _price) public onlyOwner {
//         price = _price;
//     }
// }

// contract Mutex {
//     bool locked;
//     modifier noReentrancy() {
//         require(
//             !locked,
//             "Reentrant call."
//         );
//         locked = true;
//         _;
//         locked = false;
//     }

//     /// This function is protected by a mutex, which means that reentrant calls from within `msg.sender.call` cannot call `f` again.
//     /// The `return 7` statement assigns 7 to the return value but still executes the statement `locked = false` in the modifier.
//     function f() public noReentrancy returns (uint) {
//         (bool success,) = msg.sender.call("");
//         require(success);
//         return 7;
//     }
// }

// //////////////////////////////////////////////////////////////////////////////////////////////////////////


// Source code at https://courses.consensys.net/courses/take/blockchain-developer-bootcamp-registration-2020/texts/14509386-10-1-smart-contract-design-patterns
contract CircuitBreaker {

    bool public stopped = false;

    modifier stopInEmergency { require(!stopped); _; }
    modifier onlyInEmergency { require(stopped); _; }

    function deposit() stopInEmergency public { 
      // Stop customer's token from being used towards a product that's no longer available.
    }
    function withdraw() onlyInEmergency public {  
      // Return any ether used in faulty transaction.
    } 
}

// Fund splitter contract on Github: https://gist.github.com/critesjosh/80d41928db2310684bc7660aa45873da
// The split() function handles the accounting and divides the msg.value sent with the transaction. 
// Another function, withdraw(), allows accounts to transfer their balance from the contract to their account.
// This pattern is also called the withdrawal pattern. It protects against re-entrancy and DoS attacks.
contract Splitter {

    mapping(address => uint) public balances;

    function split(address address1, address address2)  // no external calls, so it will not fail
	public
	payable
	returns(bool success)
    {
	require(msg.value > 1);
	require(address1 != address(0));
	require(address2 != address(0));
        uint amount = (msg.value - (msg.value % 2)) / 2;
        balances[address1] += amount;
        balances[address2] += amount;
        balances[msg.sender] += msg.value % 2;
	return true;
    }

    function withdraw()
	public
	returns(bool success)
    {
	require(balances[msg.sender] > 0);
	uint amount = balances[msg.sender];
	balances[msg.sender] = 0;
	msg.sender.transfer(amount);
	return true;
    }
}
