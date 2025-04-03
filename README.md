# Lending & Borrowing Protocol CTF

## Introduction
Welcome to the **Lending & Borrowing Protocol CTF**! This Capture The Flag (CTF) challenge is designed to help participants gain confidence in working with decentralized finance (DeFi) lending and borrowing protocols. Through this challenge, you'll explore key functionalities, critical points, and potential pitfalls that arise in real-world smart contracts.

## Objective
The objective of this CTF is to analyze and interact with a lending and borrowing protocol that mimics real-world implementations. Participants will:

- Understand the core mechanisms behind lending and borrowing.
- Identify critical points that should always be checked during an audit.
- Exploit weaknesses in the smart contract to achieve specific goals within the challenge.
- Gain hands-on experience in DeFi security and smart contract analysis.

## Protocol Overview
The lending and borrowing protocol in this repository implements fundamental DeFi functionalities, including:

- **Lend:** Users can deposit funds into the protocol and earn interest.
- **Borrow:** Users can take loans by providing collateral.
- **Repay:** Borrowers can repay their loans to avoid liquidation.
- **Modify Collateral:** Borrowers can adjust their collateral to maintain a healthy position.
- **Liquidate:** If a borrower becomes undercollateralized, their position can be liquidated.

## Rules
- Do not deploy or use modified versions of the contracts for unintended exploits.
- Create a POC in a foundry test file for each of the vulnerabilities.

## Vulnerabilities

The contract contains six (6) intentionally embedded vulnerabilities. These represent common security flaws in lending and borrowing protocols. Participants should analyze the code, find these vulnerabilities, and exploit them in a controlled environment.

- Vulnerabilities:
1. Lender should be able to create 2 different lendings without loosing the first one. ✅✅
2. Borrower should be able to create 2 different borrows without loosing the first one (if not he could steal funds from first one) ✅✅
3. Borrower should not be able to deposit wrong collateral for a pool ✅✅
4. Borrower should not be able to modify an existing position to an unhealthy state (instantly liquidated) ✅✅
5. Interest should not be accounting if protocol is paused ✅✅
6. There should be a grace period of users not getting liquidated after the protocol being paused (so users have the oportunity to pay the debt back) ✅✅
