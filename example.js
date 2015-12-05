util.ajaxRequest({
  method: "GET",
  url: "",
  successCallback: function(data) {

  },
  errorCallback: function(e) {
    console.log("There is an error" + e);
  }
});

util.ajaxRequest({
  method: "POST",
  url: "",
  data: {
    // Data to send to API here
  },
  successCallback: function(data) {

  },
  errorCallback: function(e) {
    console.log("There is an error" + e);
  }
});
