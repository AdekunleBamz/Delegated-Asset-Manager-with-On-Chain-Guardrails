---
name: Bug Report
description: Report a bug or issue with the Delegated Asset Manager smart contracts
title: "[BUG] "
labels: ["bug", "needs-triage"]
assignees: []
---

## 🐛 Bug Description
A clear and concise description of what the bug is.

## 🔄 Steps to Reproduce
1. Go to '...'
2. Deposit/withdraw assets from vault '....'
3. Execute trading strategy '....'
4. See error

## 📋 Expected Behavior
A clear and concise description of what you expected to happen.

## 📸 Screenshots/Logs
If applicable, add screenshots or error logs to help explain your problem.

## 🌐 Environment
- **Clarity Version**: [e.g., Clarity 4.0]
- **Stacks Network**: [e.g., Mainnet, Testnet]
- **Contract Version**: [e.g., 1.0.0]
- **Clarinet Version**: [e.g., 2.3.0]

## 💰 Vault Details (if applicable)
- **Vault Address**: [Contract address]
- **User Balance**: [e.g., 1000 STX]
- **Delegated Amount**: [e.g., 500 STX]
- **Guardrail Settings**: [Slippage %, Max amount, etc.]

## 📊 Transaction Details (if applicable)
- **Transaction Type**: [Deposit/Withdraw/Execute Strategy]
- **Asset Type**: [STX, SIP009 NFT, SIP010 Token]
- **Amount**: [e.g., 100 STX]
- **Strategy ID**: [Strategy identifier]
- **Transaction ID**: [Stacks transaction ID]
- **Block Height**: [Block number]

## 🛡️ Guardrail Violations (if applicable)
- **Guardrail Type**: [Slippage/Max Amount/Token Whitelist]
- **Expected Value**: [e.g., Min 95 STX output]
- **Actual Value**: [e.g., Got 90 STX output]
- **Violation Reason**: [Specific guardrail that failed]

## 📈 Strategy Execution (if applicable)
- **Strategy Type**: [DEX Trading, Arbitrage, etc.]
- **Input Parameters**: [Strategy configuration]
- **Expected Outcome**: [Expected profit/loss]
- **Actual Outcome**: [Actual results]

## 📝 Additional Context
Add any other context about the problem here, such as:
- When did this start happening?
- Is this related to a specific asset or strategy?
- Any recent contract deployments or updates?

## ✅ Verification Steps
- [ ] I have tested this with multiple assets
- [ ] I have verified guardrail settings
- [ ] I have checked vault balances before and after
- [ ] I have tested both delegated and direct transactions
- [ ] I have verified contract state on Stacks Explorer