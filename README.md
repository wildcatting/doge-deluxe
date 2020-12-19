# Doge Emporium

### About
Doge Emporium is an expanded DApp based on Truffle's [Pet Shop Tutorial](https://www.trufflesuite.com/tutorials/pet-shop), where the shop is offering a special "Buy one and get your second free" discount.

### Usage
To purchase a doge, the user needs to connect their [MetaMask Wallet](https://metamask.io). Once connected, the user's current wallet address will display below the shop logo. The owner of the shop can also revert all transactions, which allows customers to withdraw amounts they spent int the store. Only the owner can reset shop transactions and only customers who previously made purchases may withdraw ETH.


## Installation

Clone this repo to your local machine:

```Bash
git clone https://github.com/jun-sung/doge-emporium.git
cd doge-emporium
```

To interact with Doge Emporium, we'll be loading the project onto a local blockchain, and to do that we'll be using Ganache.
If you haven't already, you'll need to install

`ganache-cli` via npm:

```Bash
npm install -g ganache-cli
```

or [Ganache GUI](https://www.trufflesuite.com/ganache).

By default, Ganache should be running on port 8545.
![Optional Text](./GanacheGUI.png)
If not, you can change the Port Number to 8545 under the Server tab in Settings.

Our truffle-config.js file is currently set to run development on Port 8545.
```javascript
networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
}
```

Since Doge Emporium is a Truffle project, we'll be using Truffle's command tools to compile, test, and migrate contracts onto .

Within the project directory, run the following commands in the terminal:

```Bash 
truffle compile
truffle test
truffle migrate
```

If there are no errors, let's run the DApp on the our local blockchain!

```Bash
npm run dev
```
