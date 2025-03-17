# lending-borrowing-ctf

- Vulnerabilities:
1. Lender should be able to create 2 different lendings without loosing the first one. ✅
2. Borrower should be able to create 2 different borrows without loosing the first one (if not he could steal funds from first one) ✅
3. Borrower should not be able to deposit wrong collateral for a pool ✅
4. Users should not be able to modify an existing position to an unhealthy state (instantly liquidated) ✅
5. Interest should not be accounting if protocol is paused
6. There should be a grace period of users not getting liquidated after the protocol being paused (so users have the oportunity to pay the debt back)