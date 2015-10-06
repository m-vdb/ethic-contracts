db.contracts.update({name: "ethic_main"}, {
  $set: {
    abi: <%= contents.contracts.ethic_main.abi %>,
    address: '0x<%= address %>'
  }
})
