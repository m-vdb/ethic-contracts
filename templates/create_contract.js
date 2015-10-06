var EthicContract = web3.eth.contract(<%= contents.contracts.ethic_main.abi %>);
var contract = EthicContract.new({
  from: web3.eth.accounts[0],
  data: '<%= contents.contracts.ethic_main.bin %>',
  gas: <%= gas %>
}, function (e, c) {
  if (!e) {
    if (!c.address) console.log('Transaction hash ' + c.transactionHash);
    else console.log('Contract address ' + c.address);
  } else {
    console.log('Error: ' + e);
  }
});
