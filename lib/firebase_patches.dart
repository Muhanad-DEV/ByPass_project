// This file contains workarounds for Firebase issues
// It should be imported before any Firebase imports

import 'dart:js' as js;
import 'package:flutter/foundation.dart' show kIsWeb;

// Define a class to patch or provide the missing methods
class FirebaseWebPatch {
  // Initialize the patch
  static void apply() {
    // Only apply in web platform
    if (!kIsWeb) return;
    
    // Inject the required JavaScript functions into the global context
    js.context.callMethod('eval', ['''
      // Define the PromiseJsImpl class that is missing
      class PromiseJsImpl {
        constructor(promise) {
          this.promise = promise;
        }
      }

      // Define the missing utility functions
      function dartify(jsObject) {
        return jsObject;
      }

      function jsify(dartObject, customJsify) {
        return dartObject;
      }

      // Define handleThenable method
      function handleThenable(promise) {
        return promise;
      }

      // Expose these functions globally
      window.dartify = dartify;
      window.jsify = jsify;
      window.handleThenable = handleThenable;
      window.PromiseJsImpl = PromiseJsImpl;
    ''']);
    
    print('Firebase web patches applied successfully');
  }
} 