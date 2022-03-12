// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

contract CumulativeBet {
    struct Player {
        uint256 balance;
        uint256 bet;
        uint8 stage;
        bool challenging;
    }

    mapping(address => Player) public players;

    uint256 public balance;

    event Started(uint256 betAmount);
    event Lost(uint256 betAmount, uint256 stage);
    event Won(uint256 amount, uint256 stage);
    event Passed(uint256 amount, uint8 stage);

    error InsufficientFunds(uint256 funds, uint256 bet);

    // From https://stackoverflow.com/questions/48848948/how-to-generate-a-random-number-in-solidity
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            ) % 100;
    }

    function fund() public payable {
        balance += msg.value;
        players[msg.sender].balance += msg.value;
    }

    function withdraw() public {
        uint256 amount = players[msg.sender].balance;
        players[msg.sender].balance = 0;
        payable(msg.sender).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return players[msg.sender].balance;
    }

    function start(uint256 bet) public {
        require(bet > 0, "Bet must be greater than 0");
        require(
            bet <= balance,
            "The bet is too high for the contract balance, try a lower bet"
        );
        require(players[msg.sender].bet == 0, "You have already started a bet");

        if (players[msg.sender].balance < bet)
            revert InsufficientFunds({
                funds: players[msg.sender].balance,
                bet: bet
            });

        players[msg.sender].stage = 0;
        players[msg.sender].balance -= bet;
        players[msg.sender].bet = bet;
        players[msg.sender].challenging = false;
        balance -= bet;
        emit Started(bet);
    }

    function challenge() public {
        require(players[msg.sender].challenging == false, "You have already started a challenge");
        players[msg.sender].challenging = true;

        uint256 bet = players[msg.sender].bet;
        require(bet > 0, "You have not started a bet");

        uint8 stage = players[msg.sender].stage;
        uint256 margin = (bet / 10);
        // Possible gains after this challenge
        uint256 gains = (stage + 1) * margin;

        // Checks if the bank can afford it
        if (balance < margin)
            end();

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

    function end() public {
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
}
