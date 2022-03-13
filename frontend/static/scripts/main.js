let batm_contract;
let user_account;

function startApp() {
    let batm_address = "";
    batm_contract = new web3.eth.Contract(batm_abi, batm_address);

    setInterval(function () {
        // Check if account has changed
        if (web3.eth.accounts[0] !== user_account) {
            user_account = web3.eth.accounts[0];
            // Call a function to update the UI with the new account
        }
    }, 100);

    startSketch();
}

function fund(amount) {
    batm_contract.methods.fund(amount).send({
        from: user_account,
        value: web3.utils.toWei(amount, "ether"),
    });
}

function withdraw() {
    batm_contract.methods.withdraw().send({
        from: user_account,
    }).on(
        "receipt",
        function (receipt) {
            console.log(receipt);
        }
    );
}

function getBalance() {
    return batm_contract.methods.getaBlance().call();
}

function start() {
    batm_contract.methods.start().send({
        from: user_account,
    }).on(
        "receipt",
        function (receipt) {
            console.log(receipt);
        }
    );
}


window.addEventListener('load', async function () {

    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof window.ethereum !== 'undefined') {
        // Use Mist/MetaMask's provider
        await window.ethereum.request({method: 'eth_requestAccounts'});
        window.web3 = new Web3(window.ethereum);
    } else {
        // Handle the case where the user doesn't have web3. Probably
        // show them a message telling them to install MetaMask in
        // order to use our app.
    }

    // Now you can start your app & access web3js freely:
    startApp()

})
