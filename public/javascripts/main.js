/*
 * Create HTML5 elements for IE's sake
 * Reference: http://ejohn.org/blog/html5-shiv/
 * Reference: http://remysharp.com/2009/01/07/html5-enabling-script/
 */

document.createElement("section");
document.createElement("article");
document.createElement("aside");
document.createElement("time");
document.createElement("button");



function facebookInit(config) {
  Config = config;

  FB.init({
    appId: Config.appId,
    xfbml: true,
    channelUrl:
      window.location.protocol + '//' + window.location.host + '/channel.html'
  });
  FB.Event.subscribe('auth.sessionChange', handleSessionChange);
  FB.Canvas.setAutoResize();

  // ensure we're always running on apps.facebook.com
  if (window == top) { goHome(); }
}

function handleSessionChange(response) {
  if ((Config.userIdOnServer && !response.session) ||
      Config.userIdOnServer != response.session.uid) {
    goHome();
  }
}

function goHome() {
  top.location = 'http://apps.facebook.com/' + Config.canvasName + '/';
}

function setDateFields(date) {
  document.getElementById('date_year').value = date.getFullYear();
  document.getElementById('date_month').value = date.getMonth();
  document.getElementById('date_day').value = date.getDate();
}
function dateToday() {
  setDateFields(new Date());
}
function dateYesterday() {
  var date = new Date();
  date.setDate(date.getDate() - 1);
  setDateFields(date);
}

function publishRun(title) {
  FB.ui({
    method: 'stream.publish',
    attachment: {
      name: title,
      caption: "I'm running!",
      media: [{
        type: 'image',
        href: 'http://runwithfriends.appspot.com/',
        src: 'http://runwithfriends.appspot.com/splash.jpg'
      }]
    },
    action_links: [{
      text: 'Join the Run',
      href: 'http://runwithfriends.appspot.com/'
    }],
    user_message_prompt: 'Tell your friends about the run:'
  });
}

//$(window).trigger("LVRS_LOAD");