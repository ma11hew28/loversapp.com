window.fbAsyncInit = function() {
  FB.init({
    appId      : '50601675619',
    channelUrl : '//loversapp.herokuapp.com/facebook/channel.html',
  });

  FB.api('/me/friends', function(friends) {
    console.log(friends);
  });

  // Add click event listener to Share button.
  document.getElementsByTagName('button')[0].addEventListener('click', function() {
    FB.api('/me/mylovers:love', 'post', { profile : 'http://facebook.com/profile.php?id=4' }, function (response) {
      if (!response || response.error) {
        alert('Error occured');
      } else {
        console.log(response);
      }      
    });    
  }
};

// Load the SDK's source Asynchronously
(function(d){
  var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
  if (d.getElementById(id)) {return;}
  js = d.createElement('script'); js.id = id; js.async = true;
  js.src = "//connect.facebook.net/en_US/all.js";
  ref.parentNode.insertBefore(js, ref);
}(document));
