App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    // Load pets.
    $.getJSON('../pets.json', function(data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');

      for (i = 0; i < data.length; i ++) {
        petTemplate.find('.panel-title').text(data[i].name);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-breed').text(data[i].breed);
        petTemplate.find('.pet-age').text(data[i].age);
        petTemplate.find('.pet-location').text(data[i].location);
        petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

        petsRow.append(petTemplate.html());
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Purchase.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var PurchaseArtifact = data;
      App.contracts.Purchase = TruffleContract(PurchaseArtifact);
    
      // Set the provider for our contract
      App.contracts.Purchase.setProvider(App.web3Provider);

      App.displayAccount();
      App.hideAdminFunctionality();
      App.hideRefundButton();
      // Use our contract to retrieve and mark the purchased pets
      App.markPurchased();
      App.addAccountChangeListener();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handlePurchase);
    $(document).on('click', '#reset-button', App.reset);
    $(document).on('click', '#refund-button', App.withdraw);
  },

  addAccountChangeListener: function() {
    window.ethereum.on('accountsChanged', function(accounts) {
      location.reload(true);
    });
  },

  displayAccount: function() {
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      if (accounts[0]) {
        $('#account').text(accounts[0]);
      }
    });
  },

  hideAdminFunctionality: function() {
    App.contracts.Purchase.deployed().then(function(instance) {
      instance.isAdmin().then(function(isAdmin) {
        if (!isAdmin) {
          $('#reset-button').hide();
        }
      });
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  hideRefundButton: function() {
    App.contracts.Purchase.deployed().then(function(instance) {
      instance.refundAvailable().then(function(refundAvailable) {
        if (!refundAvailable) {
          $('#refund-button').hide();
        }
      });
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  markPurchased: function() {
    var purchaseInstance;

    App.contracts.Purchase.deployed().then(function(instance) {
      purchaseInstance = instance;

      return purchaseInstance.getPurchasers.call();
    }).then(function(purchasers) {
      for (i = 0; i < purchasers.length; i++) {
        if (purchasers[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-pet').eq(i).find('button').text('Purchased (No longer available)').attr('disabled', true);
        }
      }
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handlePurchase: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Purchase.deployed().then(function(instance) {
        instance.eligibleDiscount().then(function(eligibleDiscount) {
          var value;
          if (!eligibleDiscount) {
            value = 1000000000000000000;
          }
          instance.purchase(petId, {from: account, value}).then(function() {
            App.markPurchased();
          });
        }).catch(function () {
          instance.circuitBreaker();
        });
      }).catch(function(error) {
        console.log(error);
      });
    });
  },

  withdraw: function(event) {
    event.preventDefault();
    App.contracts.Purchase.deployed().then(function(instance) {
      // Execute purchase as a transaction by sending account
      instance.withdraw().then(function() {
        App.hideRefundButton();
      });
    }).catch(function(error) {
      console.log(error);
    });
  },

  reset: function(event) {
    event.preventDefault();
    App.contracts.Purchase.deployed().then(function(instance) {
      // Execute purchase as a transaction by sending account
      instance.reset().then(function() {
        location.reload(true);
      });
    }).catch(function(error) {
      console.log(error);
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
