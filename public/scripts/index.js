window.fbAsyncInit = function () {
  FB.Event.subscribe('auth.statusChange', function (response) {
    if (response.status != 'connected') { // 'not_authorized' or 'unknown'
       window.top.location = 'https://www.facebook.com/dialog/oauth/?client_id=50601675619&redirect_uri=https%3A%2F%2Fapps.facebook.com%2Fmylovers%2F&scope=publish_actions';
    } else {                              // 'connected'
      FB.api('/me/friends', function (response) {
        // console.log(response);
    
        if (!response) {
          alert('Unknown Error');          
        } else {
          var error = response.error;
          if (error) {
            alert('Error: '+error.type+' '+error.message);
          } else {
            // Create a <select> element and fill it with friends as <option> elements.
            var friendSelectorNew = document.createElement('select');
            var friendOption = document.createElement('option');
            friendOption.appendChild(document.createTextNode('Select a friend.'));            
            friendSelectorNew.appendChild(friendOption);
            var friends = response.data; // [{"id": "514417", "name": "Matt Di Pasquale"}, ... ]
            for (var i = 0; i < friends.length; i++) {
              var friend = friends[i];
              friendOption = document.createElement('option');
              friendOption.setAttribute('value', friend.id);
              friendOption.appendChild(document.createTextNode(friend.name));
              friendSelectorNew.appendChild(friendOption);
            }
            var friendSelectorOld = document.getElementsByTagName('select')[0];
            friendSelectorOld.parentNode.replaceChild(friendSelectorNew, friendSelectorOld);
          }
        }
      });

      // Add click event listener to Share button.
      var shareButton = document.getElementsByTagName('button')[0];
      shareButton.addEventListener('click', function () {
        shareButton.disabled = true;
        var targetID = document.getElementsByTagName('select')[0].value;
        FB.api('/me/mylovers:love', 'post', { profile : 'http://facebook.com/profile.php?id='+targetID }, function (response) {
          if (!response) {
            alert('Unknown Error');          
          } else {
            var error = response.error;
            if (error) {
              alert('Error: '+error.type+' '+error.message);
            } else {
              alert('Success! Love shared. Check your profile.');
            }
          }
          shareButton.disabled = false;
        });
      });
    }
  });

  FB.init({
    appId      : '50601675619',
    channelUrl : '//loversapp.herokuapp.com/facebook/channel.html'
  });
};

// Load the SDK's source Asynchronously.
(function(d){
  var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
  if (d.getElementById(id)) {return;}
  js = d.createElement('script'); js.id = id; js.async = true;
  js.src = "//connect.facebook.net/en_US/all.js";
  ref.parentNode.insertBefore(js, ref);
}(document));
