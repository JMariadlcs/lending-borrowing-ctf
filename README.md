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

## Vulnerabilities

The contract contains six (6) intentionally embedded vulnerabilities. These represent common security flaws in lending and borrowing protocols. Participants should analyze the code, find these vulnerabilities, and exploit them in a controlled environment.

## Rules
- Do not deploy or use modified versions of the contracts for unintended exploits.
- Create a POC in a foundry test file for each of the vulnerabilities.
