# AVOIDING COMMON ATTACKS

# MetaMask Re-Entrancy
Upon testing, it was discovered that a customer could load up pending transactions on MetaMask, leading to buying the first dog and then hacking the get-one-free discount by loading up the remaining fifteen available dogs in the cart. By loading up these pending transactions, the customer could get any remaining dogs in the store for free. This bug was addressed by adding an extra check before the purchase function completed as to whether a customer was indeed eligible for the discount, as any transactions in MetaMask would change the customer's state.

# DoS
The reset function in Solidity.sol originally contained the refund.