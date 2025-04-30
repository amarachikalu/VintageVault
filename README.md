# VintageVault

A decentralized marketplace for vintage clothing items built on the Stacks blockchain.

## Overview

VintageVault enables users to list, buy, and verify the authenticity of vintage clothing items. The platform leverages blockchain technology to provide immutable provenance tracking for each item, ensuring authenticity and ownership history.

## Features

- List vintage clothing items with details like name, description, year, and price
- Purchase items using STX tokens
- Track complete ownership history of each item
- Authentication system for verifying item authenticity
- Immutable record of all transactions and ownership transfers

## Smart Contract Functions

### Public Functions

- `list-item`: Create a new listing for a vintage clothing item
- `purchase-item`: Buy a listed item, transferring ownership and STX
- `authenticate-item`: Mark an item as authenticated (admin only)

### Read-Only Functions

- `get-item`: Retrieve details about a specific item
- `get-item-history`: View historical records for an item at a specific index
- `get-history-length`: Get the number of historical records for an item

## Development

This project is built using Clarity smart contracts on the Stacks blockchain.

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://github.com/blockstack/stacks.js)

### Testing

Run tests using Clarinet:

```bash
clarinet test