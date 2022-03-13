// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

import "./ownable.sol";

/// @title A bet on a serie of wins
/// @author Thomas Juldo
/// @notice You can use this contract to play a game
/// @dev Check for possible vulnerabilities and math errors
contract CumulativeBet is Ownable {
    struct Player {
        uint256 balance;
        uint256 bet;
        uint8 stage;
        bool challenging;
    }

    mapping(address => Player) public players;

    uint256 public balance;
    uint256 public maxBet = 0.1 ether;

    event Started(uint256 betAmount);
    event Lost(uint256 betAmount, uint256 stage);
    event Won(uint256 amount, uint256 stage);
    event Passed(uint256 amount, uint8 stage);

    error InsufficientFunds(uint256 funds, uint256 bet);

    /// @notice Generates a random number between 0 and 100 from https://stackoverflow.com/questions/48848948/how-to-generate-a-random-number-in-solidity
    /// @dev This function is pseudo-random
    /// @return RandomNumber in uint256 format between 0 and 100
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            ) % 100;
    }

    /// @notice Adds funds to the contract and the balance of the player
    /// @dev Could add a maximum amount of funds
    function fund() external payable {
        balance += msg.value;
        players[msg.sender].balance += msg.value;
    }

    /// @notice Withdraws funds from the contract and the balance of the player
    /// @dev Check if the contract has enough funds
    function withdraw() external {
        uint256 amount = players[msg.sender].balance;
        players[msg.sender].balance = 0;
        balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    /// @notice Gets the balance of the player
    /// @return Balance of the player
    function getBalance() external view returns (uint256) {
        return players[msg.sender].balance;
    }

    /// @notice Starts a game
    function start(uint256 _bet) external {
    /// @param bet Amount of ether to bet
        require(_bet > 0, "Bet must be greater than 0");
        require(_bet < maxBet, "Bet must be less than max bid value");
        require(
            _bet <= balance,
            "The bet is too high for the contract balance, try a lower bet"
        );
        require(players[msg.sender].bet == 0, "You have already started a bet");

        if (players[msg.sender].balance < _bet)
            revert InsufficientFunds({
                funds: players[msg.sender].balance,
                bet: _bet
            });

        players[msg.sender] = Player({
            balance: players[msg.sender].balance - _bet,
            bet: _bet,
            stage: 0,
            challenging: false
        });
        balance -= _bet;
        emit Started(_bet);
    }

    /// @notice Challenges the next stage
    function challenge() external {
        require(
            players[msg.sender].challenging == false,
            "You have already started a challenge"
        );
        players[msg.sender].challenging = true;

        uint256 bet = players[msg.sender].bet;
        require(bet > 0, "You have not started a bet");

        uint8 stage = players[msg.sender].stage;
        uint256 margin = (bet / 10);
        // Possible gains after this challenge
        uint256 gains = (stage + 1) * margin;

        // Checks if the bank can afford it
        if (balance < margin) this.end();

        balance -= margin;

        if (random() > 10 + stage * 1) {
            players[msg.sender].stage += 1;

            emit Passed(bet + gains, stage + 1);
        } else {
            players[msg.sender].bet = 0;
            players[msg.sender].stage = 0;
            balance += bet + gains;

            emit Lost(bet, stage + 1);
        }

        players[msg.sender].challenging = false;
    }

    /// @notice Ends the game with a win for the player
    /// @dev Checks if the player has started a bet, which means he is playing and has not lost yet.
    function end() external {
        uint256 bet = players[msg.sender].bet;
        require(bet > 0, "You have not started a bet");

        uint8 stage = players[msg.sender].stage;
        uint256 amount = bet + stage * (bet / 10);

        players[msg.sender].bet = 0;
        players[msg.sender].stage = 0;
        players[msg.sender].balance += amount;
        balance -= amount + bet;
        emit Won(
            players[msg.sender].bet +
                (players[msg.sender].stage * players[msg.sender].bet) /
                10,
            players[msg.sender].stage
        );
    }

    /// @notice Withdraws all funds from the contract
    /// @dev Only the owner can withdraw all funds
    function withdrawAllFunds() external onlyOwner {
        uint256 amount = balance;
        balance = 0;
        payable(msg.sender).transfer(amount);
    }

    /// @notice Sets a new value for the max bet allowed
    /// @dev Only the owner can set the max bet
    function setMaxBet(uint256 _maxBet) external onlyOwner {
        maxBet = _maxBet;
    }
}
