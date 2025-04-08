# Blockchain-Based Pharmaceutical Clinical Trial Supply

This project implements a set of smart contracts using Clarity language to manage pharmaceutical clinical trials on the blockchain. The system provides transparency, security, and traceability for the entire clinical trial supply chain.

## Overview

The system consists of four main smart contracts:

1. **Manufacturer Verification Contract**: Validates legitimate drug producers
2. **Randomization Contract**: Manages blinded distribution of trial medications
3. **Temperature Monitoring Contract**: Ensures proper storage conditions
4. **Inventory Tracking Contract**: Monitors drug supply at research sites

## Smart Contracts

### Manufacturer Verification Contract

This contract maintains a registry of verified pharmaceutical manufacturers. It includes:

- Functions to add and verify manufacturers
- Ability to deactivate manufacturers
- Ownership management for contract administration

### Randomization Contract

This contract manages the randomized, blinded distribution of trial medications to ensure unbiased clinical trials. It includes:

- Trial creation and management
- Random treatment assignment for participants
- Blinded access to treatment assignments

### Temperature Monitoring Contract

This contract ensures that medications are stored under proper conditions. It includes:

- Setting temperature and humidity thresholds for batches
- Recording temperature readings
- Tracking compliance violations

### Inventory Tracking Contract

This contract monitors the drug supply at research sites. It includes:

- Product registration at sites
- Inventory receipt and dispensing
- Transaction history tracking

## Getting Started

### Prerequisites

- Clarity development environment
- Vitest for running tests

### Installation

1. Clone the repository:
