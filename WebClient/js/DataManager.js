var util = (function(){

  function ajaxRequest(options) {
    var apiUrl = "https://api.parse.com/1/classes/";

    var ajaxOptions = {
      type: options.method,
      url:  apiUrl + options.url,
      contentType: options.contentType ? options.contentType : 'application/json',
      success: function(response) {
        options.successCallback(response);
      },
      error: function(e) {
        e = e || {};
        console.log("Something went wrong...", e.responseJSON || e);

        if (options.errorCallback) options.errorCallback(e);
      },
      complete: function(e) {
        if (options.doneCallback) options.doneCallback(e);
      }
    }

    if (options.postData) {
      ajaxOptions.data = ajaxOptions.contentType == 'application/json' ? JSON.stringify(options.postData) : options.postData;
    }

    ajaxOptions.headers = {
      "X-Parse-Application-Id" : "xKchtsJYcrBTan4IcSTclsiC8iStBqLapaL4ifMQ",
      "X-Parse-REST-API-Key" : "3YE60uKXf9Mdrs6bqMoT0IWfUWFpMcLfIUegaHL3"
    };

    $.ajax(ajaxOptions);
  }


  return {
    ajaxRequest: ajaxRequest
  }
})();
