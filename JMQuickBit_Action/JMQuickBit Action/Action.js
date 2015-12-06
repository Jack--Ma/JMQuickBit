//
//  Action.js
//  JMQuickBit Action
//
//  Created by JackMa on 15/12/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        // Here, you can run code that modifies the document and/or prepares
        // things to pass to your action's native code.
        
        // We will not modify anything, but will pass the body's background
        // style to the native code.
      arguments.completionFunction({ "currentURL" : document.URL })
    },
    
    finalize: function(arguments) {
        // This method is run after the native code completes.
        
        // We'll see if the native code has passed us a new background style,
        // and set it on the body.
      var error = arguments["error"];
      if (error) {
        alert('There was an error creating your bit.ly link');
      } else {
        var shortURL = arguments["shortURL"];
        alert('Your bit.ly link is now on your clipboard\n\n' + shortURL);
      }
    }
    
};
    
var ExtensionPreprocessingJS = new Action
