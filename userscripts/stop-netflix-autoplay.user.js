// ==UserScript==
// @author        TheMercDeadpool
// @namespace     https://openuserjs.org/users/TheMercDeadpool
// @name          Stop Netflix Autoplay
// @description   Stops the Netflix billboard/ preview video and audio from playing.
// @copyright     2018, TheMercDeadpool (https://openuserjs.org/users/TheMercDeadpool)
// @license       MIT
// @version       0.3
// @include       https://www.netflix.com/browse*
// @require       https://code.jquery.com/jquery-3.3.1.min.js
// ==/UserScript==

// ==OpenUserJS==
// @author TheMercDeadpool
// ==/OpenUserJS==

(function() {
    'use strict';

    $('body').bind('DOMSubtreeModified', function () {
       $(".billboard .VideoContainer video").each(function () { this.remove(); });
       $(".video-component-container video").each(function () { this.remove(); });
       $(".billboard audio").each(function () { this.remove(); });
    });

})();
