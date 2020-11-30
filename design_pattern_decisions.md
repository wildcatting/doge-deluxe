# Circuit Breaker
The circuit breaker was implemented to address the case where two or more customers attempting to purchase the same dog within a short enough window of time would not be alerted by the site if someone purchases said dog moments beforehand. The breaker would prevent subsequent customers from sending their ether since their dog of choice is no longer available.

# Restricted Access
The restricted access design pattern was implemented primarily because a reset function was included and this should only be accessible to the admin/owner of the contract.