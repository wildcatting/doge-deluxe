# MetaMask Re-Entrancy

Upon testing, it was discovered that a customer could load up pending transactions on MetaMask. After buying the first dog, an account could then hack the get-one-free discount by loading up the remaining available dogs in the cart. By loading up these pending transactions, the account could get every remaining dog in the store for free. This bug was addressed by adding an extra requirement verifying whether an account is still eligible for the discount, since a single transaction in MetaMask changes the contract state.

# Denial of Service (DoS)

Initially, the reset function reverted all purchases and returned accumulated balances to every account that had transacted with the store. However, it was vulnerable to a DoS attack in which a single external transfer call throwing would 1) prevent the admin from being able to reset the store and 2) keep all accounts from receiving their accumulated balances. In order to address this vulnerability, the pull over push pattern was implemented where the withdraw functionality is separated into its own function.