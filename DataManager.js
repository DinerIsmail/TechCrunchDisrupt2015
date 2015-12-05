var util = (function(){

  function ajaxRequest(options) {
    var apiUrl = "";

    var ajaxOptions = {
      type: options.method,
      url:  apiUrl + options.url,
      contentType: options.contentType ? options.contentType : 'application/json',
      success: function(response) {
        options.successCallback(response);
      },
      error: function(e) {
        e = e || {};
        log("Something went wrong...", e.responseJSON || e);

        if (options.errorCallback) options.errorCallback(e);
      }
      complete: function(e) {
        if (options.doneCallback) options.doneCallback(e);
      }
    }

    if (options.postData) {
      ajaxOptions.data = ajaxOptions.contentType == 'application/json' ? JSON.stringify(options.postData) : options.postData;
    }

    ajaxOptions.headers = {
      "Authorization" : "Bearer " + access_token
    };

    $.ajax(ajaxOptions);
  }

  return {
    ajaxRequest: ajaxRequest
  }
})();
