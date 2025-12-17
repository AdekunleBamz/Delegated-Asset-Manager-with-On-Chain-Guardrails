# Delegated Asset Manager with On-Chain Guardrails

A sophisticated DAO treasury management system built on Stacks blockchain using Clarity 4.0, featuring trustless delegation with on-chain safety mechanisms.

## 🎯 Overview

This project implements a **Delegated Asset Manager** that allows a DAO treasury to delegate trading authority to human traders or AI agents while enforcing strict safety guardrails through smart contract post-conditions. The system prevents rug-pulls and ensures minimum execution quality through on-chain validation.

## ✨ Key Features

### 1. **On-Chain Guardrails** (`guardrails.clar`)
- Slippage protection with minimum output validation
- Maximum transaction amount limits
- Token whitelist management
- Pre-execution safety checks

### 2. **Vault Management** (`vault.clar`)
- Secure STX deposits and withdrawals
- User balance tracking
- Execution history logging
- Post-condition enforcement
- Emergency pause integration

### 3. **Strategy Execution** (`strategy-manager.clar`)
- Implements executor trait for standardized execution
- Automated DEX trading
- Profit/loss tracking
- Comprehensive trade logging

### 4. **Governance** (`governance.clar`)
- Admin controls
- Manager whitelist
- Emergency pause functionality
- Decentralized permission management

### 5. **Mock DEX** (`mock-dex.clar`)
- Simulated decentralized exchange
- Pool management
- Swap history tracking
- Configurable fee rates

### 6. **Trait System** (`traits.clar`)
- Executor trait for strategy standardization
- Vault trait for treasury operations
- Extensible architecture

## 🔒 Security Features

### Post-Condition Guardrails
The vault contract enforces post-conditions that **physically prevent** bad trades:

```clarity
;; Example: Minimum output check
(asserts! (>= balance-after min-expected-out) ERR-MIN-OUT)
```

This means:
- ✅ Managers can attempt trades
- ✅ Contract validates execution quality
- ✅ Transactions revert if guardrails fail
- ✅ Treasury funds are protected

### Multi-Layer Protection
1. **Pre-execution checks**: Pause state, manager authorization, fund availability
2. **Execution monitoring**: Balance tracking, strategy execution
3. **Post-execution validation**: Minimum output, slippage limits

## 🏗️ Architecture

```
┌─────────────────┐
│   Governance    │ ← Admin & Manager Control
└────────┬────────┘
         │
    ┌────▼─────┐
    │  Vault   │ ← Treasury & Execution Engine
    └────┬─────┘
         │
    ┌────▼──────────┐
    │ Strategy Mgr  │ ← Trading Logic
    └────┬──────────┘
         │
    ┌────▼─────┐
    │ Mock DEX │ ← Exchange Interface
    └──────────┘
```

## 📦 Contracts

| Contract | Purpose | Key Functions |
|----------|---------|---------------|
| `traits.clar` | Interface definitions | executor-trait, vault-trait |
| `guardrails.clar` | Safety mechanisms | check-min-out, check-max-tx |
| `governance.clar` | Access control | set-manager, set-paused |
| `vault.clar` | Treasury management | deposit, withdraw, execute-strategy |
| `strategy-manager.clar` | Trading strategies | execute (implements executor-trait) |
| `mock-dex.clar` | DEX simulation | swap, init-pool |

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- Clarity 4.0 support
- Stacks blockchain epoch 3.3

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd "Delegated Asset Manager with On-Chain Guardrails"

# Check contracts
clarinet check

# Run tests
clarinet test

# Start console
clarinet console
```

### Usage Example

```clarity
;; 1. Deposit funds into vault
(contract-call? .vault deposit u1000000)

;; 2. Admin whitelists a manager
(contract-call? .governance set-manager 'ST1MANAGER... true)

;; 3. Manager executes strategy with guardrails
(contract-call? .vault execute-strategy 
  .strategy-manager 
  u500000        ;; amount to trade
  u475000        ;; minimum acceptable output (5% slippage tolerance)
)
```

## 🧪 Testing

The project includes comprehensive tests for:
- Deposit/withdrawal flows
- Strategy execution
- Guardrail enforcement
- Emergency pause functionality
- Manager authorization

## 🛠️ Development

### Branch Strategy
This project uses feature branches for all development:
- `feat/*` - New features
- `fix/*` - Bug fixes
- `refactor/*` - Code improvements
- `docs/*` - Documentation

### Adding New Strategies
1. Implement the `executor-trait`
2. Add safety checks
3. Register with governance
4. Test with vault execution

## 📊 Clarity 4.0 Features Used

- ✅ Traits and trait implementation
- ✅ Advanced error handling
- ✅ Contract calls with post-conditions
- ✅ Map and variable state management
- ✅ Read-only function optimization

## 🔐 Security Considerations

1. **Always set appropriate minimum outputs** when executing strategies
2. **Whitelist managers carefully** - they have execution authority
3. **Monitor execution history** for suspicious patterns
4. **Use emergency pause** if issues detected
5. **Test strategies thoroughly** before mainnet deployment

## 📝 License

This project is for educational and demonstration purposes.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using Clarity 4.0 on Stacks Blockchain**
