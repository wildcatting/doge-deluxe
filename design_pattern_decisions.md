# Design Pattern Decisions

### Circuit Breaker
The circuit breaker was implemented to address the case where two or more customers attempting to buy the same doge within a short enough window of time would not be alerted by the site if someone buys said doge moments beforehand. The breaker would prevent subsequent customers from sending their ether since their dog of choice is no longer available.
```
function circuitBreaker() public {
    _stopped = true;
}
```

### Restricted Access
The restricted access design pattern was implemented primarily because a reset function was included and this should only be accessible to the owner of the contract. The onlyOwner modifier from OpenZeppelin's Ownable.sol was used.
```
modifier onlyOwner() {
    require(isOwner());
    _;
}
```