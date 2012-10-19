defmodule WDeX.WebDriver.Spec do
  use WDeX.Rest.API
  defmodule Status do
    def status(0), do: :Success # The command executed successfully.
    exceptions([
      {NoSuchElement,           7, "An element could not be located on the page using the given search parameters."},
      {NoSuchFrame,             8, "A request to switch to a frame could not be satisfied because the frame could not be found."},
      {UnknownCommand,          9, "The requested resource could not be found, or a request was received using an HTTP method that is not supported by the mapped resource."},
      {StaleElementReference,  10, "An element command failed because the referenced element is no longer attached to the DOM."},
      {ElementNotVisible,      11, "An element command could not be completed because the element is not visible on the page."},
      {InvalidElementState,    12, "An element command could not be completed because the element is in an invalid state (e.g. attempting to click a disabled element)."},
      {UnknownError,           13, "An unknown server-side error occurred while processing the command."},
      {ElementIsNotSelectable, 15, "An attempt was made to select an element that cannot be selected."},
      {JavaScriptError,        17, "An error occurred while executing user supplied JavaScript."},
      {XPathLookupError,       19, "An error occurred while searching for an element by XPath."},
      {Timeout,                21, "An operation did not complete before its timeout expired."},
      {NoSuchWindow,           23, "A request to switch to a different window could not be satisfied because the window could not be found."},
      {InvalidCookieDomain,    24, "An illegal attempt was made to set a cookie under a different domain than the current page."},
      {UnableToSetCookie,      25, "A request to set a cookie's value could not be satisfied."},
      {UnexpectedAlertOpen,    26, "A modal dialog was open, blocking this operation."},
      {NoAlertOpenError,       27, "An attempt was made to operate on a modal dialog when one was not open."},
      {ScriptTimeout,          28, "A script did not complete before its timeout expired."},
      {InvalidElementCoordinates,  29, "The coordinates provided to an interactions operation are invalid."},
      {IMENotAvailable,        30, "IME was not available."},
      {IMEEngineActivationFailed,  31, "An IME engine could not be started."},
      {InvalidSelector,        32, "Argument was an invalid selector (e.g. XPath/CSS)."},
      {SessionNotCreatedException, 33, "A new session could not be created."},
      {MoveTargetOutOfBounds,  34, "Target provided for a move action is out of bounds."}
      ])
  end

  ## Types
  record Build,
     version: nil :: string,
     revision: nil :: string,
     time: nil :: string,
     extras: [] :: list

  record OS,
     arch: nil :: string,
     name: nil :: string,
     version: nil :: string,
     extras: [] :: list

  type base64png :: string
  type engine :: string

  record Cookie,
     name: nil :: string,
     value: nil :: string,
     path: nil :: string,
     domain: nil :: string,
     secure: nil :: string,
     expiry: nil :: string

  type source :: string

  mapping Key, [
       null:       0xE000,
       cancel:     0xE001,
       help:       0xE002,
       backspace:  0xE003,
       tab:        0xE004,
       clear:      0xE005,
       return:    0xE006,
       enter:     0xE007,
       shift:      0xE008,
       control:    0xE009,
       alt:        0xE00A,
       pause:      0xE00B,
       escape:     0xE00C,

       space:      0xE00D,
       pageup:     0xE00E,
       pagedown:   0xE00F,
       end:        0xE010,
       home:       0xE011,
       left:       0xE012,
       up:         0xE013,
       right:      0xE014,
       down:       0xE015,
       insert:     0xE016,
       delete:     0xE017,
       semicolon:  0xE018,
       equals:     0xE019,

       numpad0:    0xE01A,
       numpad1:    0xE01B,
       numpad2:    0xE01C,
       numpad3:    0xE01D,
       numpad4:    0xE01E,
       numpad5:    0xE01F,
       numpad6:    0xE020,
       numpad7:    0xE021,
       numpad8:    0xE022,
       numpad9:    0xE023,

       multiply:   0xE024,
       add:        0xE025,
       separator:  0xE026,
       subtract:   0xE027,
       decimal:    0xE028,
       divide:     0xE029,

       f1:        0xE031,
       f2:        0xE032,
       f3:        0xE033,
       f4:        0xE034,
       f5:        0xE035,
       f6:        0xE036,
       f7:        0xE037,
       f8:        0xE038,
       f9:        0xE039,
       f10:       0xE03A,
       f11:	  0xE03B,
       f12:       0xE03C,
       command:   0xE03D,
       meta:      0xE03D
     ]

  record WebElement, [
      :ID :: string,
      :ELEMENT :: string
     ]

  record Session,
     id: nil :: string,
     capabilities: nil :: Capabilities

  record Capabilities,
     browserName: "" :: string,
     platform: "" :: string,
     javascriptEnabled: false :: boolean,
     takesScreenshot: false :: boolean,
     handlesAlerts: false :: boolean,
     databaseEnabled: false :: boolean,
     locationContextEnabled: false :: boolean,
     applicationCacheEnabled: false :: boolean,
     browserConnectionEnabled: false :: boolean,
     cssSelectorsEnabled: false :: boolean,
     webStorageEnabled: false :: boolean,
     rotatable: false :: boolean,
     acceptSslCerts: false :: boolean,
     nativeEvents: false :: boolean,
     proxy: nil :: Proxy

  # FIXME how to specify conversion from string to atom
  type orientation = :LANDSCAPE
                   | :PORTRAIT
                  :: atom

  mapping Button, [left: 0, middle: 1, right: 2]

  record Location,
     latitude: nil :: integer,
     longitude: nil :: integer,
     altitude: nil :: integer

  type id :: string

  type log_level = :ALL
                   | :DEBUG
                   | :INFO
                   | :WARNING
                   | :SEVERE
                   | :OFF
                 :: atom

  type log_type :: :client
                 | :driver
                 | :browser
                 | :server

  record Event, # Log Entry in original document
     timestamp: nil :: integer,
     level:     nil :: string,
     message:   nil :: string

  record Proxy,
     proxyType: nil :: string,
     proxyAutoconfigUrl: nil :: string,
     ftpProxy: nil :: string,
     httpProxy: nil :: string,
     sslProxy: nil :: string


   type strategy = "class name"
                   | "css selector"
                   | "id"
                   | "name"
                   | "link text"
                   | "partial link text"
                   | "tag name"
                   | "xpath"
                  :: string

  ## REST Methods

     @doc """
     Query the server's current status. The server should respond with a general
     "HTTP 200 OK" response if it is alive and accepting commands. The response
     body should be a JSON object describing the state of the server. All server
     implementations should return two basic objects describing the server's
     current platform and when the server was built. All fields are optional;
     if omitted, the client should assume the value is uknown. Furthermore,
     server implementations may include additional fields not listed here.
     """
     spec :get, "/status" do
       [
        name:
          :status,
        args:
          nil,
        returns:
          [build :: Build, os :: OS]
       ]
     end

     @doc """
     Create a new session. The server should attempt to create a session that
     most closely matches the desired and required capabilities. Required
     capabilities have higher priority than desired capabilities and must
     be set for the session to be created.
     """
     spec :post, "/session" do
       [
        name:
          :session,
        args:
          [desiredCapabilities :: Capabilities, requiredCapabilities :: Capabilities],
        returns:
          redirect(303, "/session/:sessionId"),
        exceptions: [SessionNotCreatedException]
       ]
     end

     @doc """
     Returns a list of the currently active sessions.
     """
     spec :get, "/sessions" do
       [
        name:
          :sessions,
        args:
          nil,
        returns:
          [sessions :: [Session]]
       ]
     end

     @doc """
     Retrieve the capabilities of the specified session.
     """
     spec :get, "/session/:sessionId" do
       [
        name:
          :session_capabilities,
        args:
          nil,
        returns:
          [capabilities :: Capabilities]
       ]
     end

     @doc """
     Delete the session.
     """
     spec :delete, "/session/:sessionId" do
       [
        name:
          :session_delete,
        args:
          nil,
        returns:
          nil
       ]
     end

     @doc """
     Configure the amount of time that a particular type of operation can
     execute for before they are aborted and a |Timeout| error is returned
     to the client.
     """
     spec :post, "/session/:sessionId/timeouts" do
       [
        name:
          :session_timeouts,
        args:
          [type :: string, ms :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Set the amount of time, in milliseconds, that asynchronous scripts
     executed by /session/:sessionId/execute_async are permitted to run before
     they are aborted and a |Timeout| error is returned to the client.
     """
     spec :post, "/session/:sessionId/timeouts/async_script" do
       [
        name:
          :async_script_timeouts,
        args:
          [ms :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Set the amount of time the driver should wait when searching for elements.
     When searching for a single element, the driver should poll the page until
     an element is found or the timeout expires, whichever occurs first. When
     searching for multiple elements, the driver should poll the page until at
     least one element is found or the timeout expires, at which point it should
     return an empty list.

     If this command is never sent, the driver should default to an implicit wait of 0ms.
     """
     spec :post, "/session/:sessionId/timeouts/implicit_wait" do
       [
        name:
          :driver_implicit_wait,
        args:
          [ms :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Retrieve the current window handle.
     """
     spec :get, "/session/:sessionId/window_handle" do
       [
        name:
          :session_window_handle,
        args:
          nil,
        returns:
          [handle :: string],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Retrieve the list of all window handles available to the session.
     """
     spec :get, "/session/:sessionId/window_handles" do
       [
        name:
          :session_window_handles,
        args:
          nil,
        returns:
          [handles :: [string]]
       ]
     end

     @doc """
     Retrieve the URL of the current page.
     """
     spec :get, "/session/:sessionId/url" do
       [
        name:
          :session_url,
        args:
          nil,
        returns:
          [url :: string],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Navigate to a new URL.
     """
     spec :post, "/session/:sessionId/url" do
       [
        name:
          :session_url,
        args:
          [url :: string],
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Navigate forwards in the browser history, if possible.
     """
     spec :post, "/session/:sessionId/forward" do
       [
        name:
          :session_forward,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Navigate backwards in the browser history, if possible.
     """
     spec :post, "/session/:sessionId/back" do
       [
        name:
          :session_back,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Refresh the current page.
     """
     spec :post, "/session/:sessionId/refresh" do
       [
        name:
          :session_refresh,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Inject a snippet of JavaScript into the page for execution in the context of
     the currently selected frame. The executed script is assumed to be
     synchronous and the result of evaluating the script is returned to the client.

     The script argument defines the script to execute in the form of a function body.
     The value returned by that function will be returned to the client.
     The function will be invoked with the provided args array and the values
     may be accessed via the arguments object in the order specified.

     Arguments may be any JSON-primitive, array, or JSON object. JSON objects
     that define a WebElement reference will be converted to the corresponding
     DOM element. Likewise, any WebElements in the script result will be returned
     to the client as WebElement JSON objects.
     """
     spec :post, "/session/:sessionId/execute" do
       [
        name:
          :session_execute,
        args:
          [script :: string, args :: [term]],
        returns:
          [result :: term],
        exceptions:
          [NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If one of the script arguments is a WebElement that is not attached to the page's DOM.
           JavaScriptError # If the script throws an Error.
          ]
       ]
     end

     @doc """
     Inject a snippet of JavaScript into the page for execution in the context
     of the currently selected frame. The executed script is assumed to be
     asynchronous and must signal that is done by invoking the provided callback,
     which is always provided as the final argument to the function.
     The value to this callback will be returned to the client.

     Asynchronous script commands may not span page loads. If an unload event
     is fired while waiting for a script result, an error should be returned
     to the client.

     The script argument defines the script to execute in teh form of a function
     body. The function will be invoked with the provided args array and the
     values may be accessed via the arguments object in the order specified.
     The final argument will always be a callback function that must be invoked
     to signal that the script has finished.

     Arguments may be any JSON-primitive, array, or JSON object. JSON objects
     that define a WebElement reference will be converted to the corresponding
     DOM element. Likewise, any WebElements in the script result will be returned
     to the client as WebElement JSON objects.
     """
     spec :post, "/session/:sessionId/execute_async" do
       [
        name:
          :session_execute_async,
        args:
          [script :: string, args :: [term]],
        returns:
          [result :: term],
        exceptions:
          [NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If one of the script arguments is a WebElement that is not attached to the page's DOM.
           Timeout, # If the script callback is not invoked before the timout expires. Timeouts are controlled by the /session/:sessionId/timeout/async_script command.
           JavaScriptError # If the script throws an Error.
          ]
       ]
     end

     @doc """
     Take a screenshot of the current page.
     """
     spec :get, "/session/:sessionId/screenshot" do
       [
        name:
          :session_screenshot,
        args:
          [script :: string, args :: [term]],
        returns:
          [screenshot :: base64png],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     List all available engines on the machine.
     To use an engine, it has to be present in this list.
     """
     spec :get, "/session/:sessionId/ime/available_engines" do
       [
        name:
          :session_ime_available_engines,
        args:
          nil,
        returns:
          [engines :: [engine]],
        exceptions:
          [ImeNotAvailableException]
       ]
     end

     @doc """
     Get the name of the active IME engine. The name string is platform specific.
     """
     spec :get, "/session/:sessionId/ime/active_engine" do
       [
        name:
          :session_ime_active_engine,
        args:
          nil,
        returns:
          [engine :: engine],
        exceptions:
          [ImeNotAvailableException]
       ]
     end

     @doc """
     Indicates whether IME input is active at the moment (not if it's available).
     """
     spec :get, "/session/:sessionId/ime/activated" do
       [
        name:
          :session_ime_activated,
        args:
          nil,
        returns:
          boolean,
        exceptions:
          [ImeNotAvailableException]
       ]
     end

     @doc """
     De-activates the currently-active IME engine.
     """
     spec :post, "/session/:sessionId/ime/deactivate" do
       [
        name:
          :session_ime_deactivate,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [ImeNotAvailableException]
       ]
     end

     @doc """
     Make an engines that is available (appears on the list returned by
     getAvailableEngines) active. After this call, the engine will be added
     to the list of engines loaded in the IME daemon and the input sent using
     sendKeys will be converted by the active engine. Note that this is a
     platform-independent method of activating IME (the platform-specific way
     being using keyboard shortcuts
     """
     spec :post, "/session/:sessionId/ime/activate" do
       [
        name:
          :session_ime_activate,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           ImeActivationFailedException, # If the engine is not available or if the activation fails for other reasons.
           ImeNotAvailableException # If the host does not support IME
          ]
       ]
     end

     @doc """
     Change focus to another frame on the page. If the frame id is null,
     the server should switch to the page's default content.
     """
     spec :post, "/session/:sessionId/frame" do
       [
        name:
          :session_frame,
        args:
          [id :: string | number | null | WebElement],
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           NoSuchFrame # If the frame specified by id cannot be found.
          ]
       ]
     end

     @doc """
     Change focus to another window. The window to change focus to may be
     specified by its server assigned window handle, or by the value of
     its name attribute.
     """
     spec :post, "/session/:sessionId/window" do
       [
        name:
          :session_change_window,
        args:
          [name :: string],
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Close the current window.
     """
     spec :delete, "/session/:sessionId/window" do
       [
        name:
          :session_close_window,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Change the size of the specified window.
     If the :windowHandle URL parameter is "current",
     the currently active window will be resized.
     """
     spec :post, "/session/:sessionId/window/:windowHandle/size" do
       [
        name:
          :session_window_change_size,
        args:
          [width :: integer, height :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Get the size of the specified window.
     If the :windowHandle URL parameter is "current",
     the size of the currently active window will be returned.
     """
     spec :get, "/session/:sessionId/window/:windowHandle/size" do
       [
        name:
          :session_window_size,
        args:
          nil,
        returns:
          [width :: integer, height :: integer],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Change the position of the specified window.
     If the :windowHandle URL parameter is "current",
     the currently active window will be moved.
     """
     spec :post, "/session/:sessionId/window/:windowHandle/position" do
       [
        name:
          :session_window_change_position,
        args:
          [x :: integer, y :: integer],
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Get the position of the specified window.
     If the :windowHandle URL parameter is "current",
     the position of the currently active window will be returned.
     """
     spec :get, "/session/:sessionId/window/:windowHandle/position" do
       [
        name:
          :session_window_position,
        args:
          nil,
        returns:
          [x :: integer, y :: integer],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Maximize the specified window if not already maximized.
     If the :windowHandle URL parameter is "current",
     the currently active window will be maximized.
     """
     spec :post, "/session/:sessionId/window/:windowHandle/maximize" do
       [
        name:
          :session_window_maximize,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Retrieve all cookies visible to the current page.
     """
     spec :get, "/session/:sessionId/cookie" do
       [
        name:
          :session_cookie,
        args:
          nil,
        returns:
          [cookies :: [Cookie]],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Set a cookie. If the cookie path is not specified,
     it should be set to "/". Likewise, if the domain is omitted,
     it should default to the current page's domain.
     """
     spec :post, "/session/:sessionId/cookie" do
       [
        name:
          :session_set_cookie,
        args:
          [cookie :: Cookie],
        returns:
          nil
       ]
     end

     @doc """
     Delete all cookies visible to the current page.
     """
     spec :delete, "/session/:sessionId/cookie" do
       [
        name:
          :session_delete_cookies,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           InvalidCookieDomain, # If the cookie's domain is not visible from the current page.
           NoSuchWindow, # If the currently selected window has been closed.
           UnableToSetCookie # If attempting to set a cookie on a page that does not support cookies (e.g. pages with mime-type text/plain).
          ]
       ]
     end

     @doc """
     Delete the cookie with the given name.
     This command should be a no-op if there is no such cookie visible
     to the current page.
     """
     spec :delete, "/session/:sessionId/cookie/:name" do
       [
        name:
          :session_delete_cookie,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Get the current page source.
     """
     spec :get, "/session/:sessionId/source" do
       [
        name:
          :session_page_source,
        args:
          nil,
        returns:
          [source :: url], # ???
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Get the current page title.
     """
     spec :get, "/session/:sessionId/title" do
       [
        name:
          :session_page_title,
        args:
          nil,
        returns:
          [title :: string],
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Search for an element on the page, starting from the document root.
     The located element will be returned as a WebElement JSON object.
     The table below lists the locator strategies that each server should support.
     Each locator must return the first matching element located in the DOM.
      Strategy          |	Description
      class name        | 	Returns an element whose class name contains the search value; compound class names are not permitted.
      css selector      |  	Returns an element matching a CSS selector.
      id                | 	Returns an element whose ID attribute matches the search value.
      name              |	Returns an element whose NAME attribute matches the search value.
      link text         |	Returns an anchor element whose visible text matches the search value.
      partial link text |	Returns an anchor element whose visible text partially matches the search value.
      tag name          | 	Returns an element whose tag name matches the search value.
      xpath             | 	Returns an element matching an XPath expression.
     """
     spec :post, "/session/:sessionId/element" do
       [
        name:
          :session_page_element,
        args:
          [using :: strategy, value :: string],
        returns:
          [element :: WebElement], # ???
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           NoSuchElement, # If the element cannot be found.
           XPathLookupError # If using XPath and the input expression is invalid.
          ]
       ]
     end

     @doc """
     Search for an element on the page, starting from the document root.
     The located element will be returned as a WebElement JSON object.
     The table below lists the locator strategies that each server should support.
     Each locator must return the first matching element located in the DOM.
      Strategy          |	Description
      class name        | 	Returns all elements whose class name contains the search value; compound class names are not permitted.
      css selector      |  	Returns all elements matching a CSS selector.
      id                | 	Returns all elements whose ID attribute matches the search value.
      name              |	Returns all elements whose NAME attribute matches the search value.
      link text         |	Returns all anchor elements whose visible text matches the search value.
      partial link text |	Returns all anchor elements whose visible text partially matches the search value.
      tag name          | 	Returns all elements whose tag name matches the search value.
      xpath             | 	Returns all elements matching an XPath expression.
     """
     spec :post, "/session/:sessionId/elements" do
       [
        name:
          :session_page_elements,
        args:
          [using :: strategy, value :: string],
        returns:
          [elements :: [WebElement]], # ???
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           XPathLookupError # If using XPath and the input expression is invalid.
          ]
       ]
     end

     @doc """
     Get the element on the page that currently has focus.
     The element will be returned as a WebElement JSON object.
     """
     spec :post, "/session/:sessionId/element/active" do
       [
        name:
          :session_page_element_active, # ???
        args:
          [using :: strategy, value :: string],
        returns:
          [element :: WebElement], # ???
        exceptions:
          [NoSuchWindow]
       ]
     end

     @doc """
     Describe the identified element.
     Note: This command is reserved for future use;
     its return type is currently undefined.
     """
     spec :get, "/session/:sessionId/element/:id" do
       [
        name:
          :session_page_element_id, # ???
        args:
          nil,
        returns:
          nil,
        exceptions:
          [NoSuchWindow,
           StaleElementReference],
        reserved:
          true
       ]
     end

     @doc """
     Search for an element on the page, starting from the identified element.
     The located element will be returned as a WebElement JSON object.
     The table below lists the locator strategies that each server should support.
     Each locator must return the first matching element located in the DOM.
      Strategy          |	Description
      class name        | 	Returns an element whose class name contains the search value; compound class names are not permitted.
      css selector      |  	Returns an element matching a CSS selector.
      id                | 	Returns an element whose ID attribute matches the search value.
      name              |	Returns an element whose NAME attribute matches the search value.
      link text         |	Returns an anchor element whose visible text matches the search value.
      partial link text |	Returns an anchor element whose visible text partially matches the search value.
      tag name          | 	Returns an element whose tag name matches the search value.
      xpath             | 	Returns an element matching an XPath expression. The provided XPath expression must be applied to the server "as is"; if the expression is not relative to the element root, the server should not modify it. Consequently, an XPath query may return elements not contained in the root element's subtree.
     """
     spec :post, "/session/:sessionId/element/:id/element" do
       [
        name:
          :session_page_element, # ???
        args:
          [using :: strategy, value :: string],
        returns:
          [element :: WebElement], # ???
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If the element referenced by :id is no longer attached to the page's DOM.
           NoSuchElement, # If the element cannot be found.
           XPathLookupError # If using XPath and the input expression is invalid.
          ]
       ]
     end

     @doc """
     Search for multiple elements on the page, starting from the identified
     element. The located elements will be returned as a WebElement JSON objects.
     The table below lists the locator strategies that each server should support.
     Elements should be returned in the order located in the DOM.
      Strategy          |	Description
      class name        | 	Returns all elements whose class name contains the search value; compound class names are not permitted.
      css selector      |  	Returns all elements matching a CSS selector.
      id                | 	Returns all elements whose ID attribute matches the search value.
      name              |	Returns all elements whose NAME attribute matches the search value.
      link text         |	Returns all anchor elements whose visible text matches the search value.
      partial link text |	Returns all anchor elements whose visible text partially matches the search value.
      tag name          | 	Returns all elements whose tag name matches the search value.
      xpath             | 	Returns all elements matching an XPath expression. The provided XPath expression must be applied to the server "as is"; if the expression is not relative to the element root, the server should not modify it. Consequently, an XPath query may return elements not contained in the root element's subtree.
     """
     spec :post, "/session/:sessionId/element/:id/elements" do
       [
        name:
          :session_page_elements, # ???
        args:
          [using :: strategy, value :: string],
        returns:
          [elements :: [WebElement]], # ???
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If the element referenced by :id is no longer attached to the page's DOM.
           XPathLookupError # If using XPath and the input expression is invalid.
          ]
       ]
     end

     @doc """
     Click on element.
     """
     spec :post, "/session/:sessionId/element/:id/click" do
       [
        name:
          :session_page_element_click, # ???
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If the element referenced by :id is no longer attached to the page's DOM.
           ElementNotVisible # If the referenced element is not visible on the page (either is hidden by CSS, has 0-width, or has 0-height)
          ]
       ]
     end

     @doc """
     Submit a FORM element.
     The submit command may also be applied to any element that
     is a descendant of a FORM element.
     """
     spec :post, "/session/:sessionId/element/:id/submit" do
       [
        name:
          :session_page_element_submit, # ???
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Returns the visible text for the element.
     """
     spec :get, "/session/:sessionId/element/:id/text" do
       [
        name:
          :session_page_element_submit, # ???
        args:
          nil,
        returns:
          [text :: string], # ??
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Send a sequence of key strokes to an element.

     Any UTF-8 character may be specified, however, if the server
     does not support native key events, it should simulate key strokes
     for a standard US keyboard layout. The Unicode Private Use Area code points,
     0xE000-0xF8FF, are used to represent pressable, non-text keys (see Key record).

     The server must process the key sequence as follows:
      - Each key that appears on the keyboard without requiring modifiers are sent as a keydown followed by a key up.
      - If the server does not support native events and must simulate key strokes with JavaScript, it must generate keydown, keypress, and keyup events, in that order. The keypress event should only be fired when the corresponding key is for a printable character.
      - If a key requires a modifier key (e.g. "!" on a standard US keyboard), the sequence is: modifier down, key down, key up, modifier up, where key is the ideal unmodified key value (using the previous example, a "1").
      - Modifier keys (Ctrl, Shift, Alt, and Command/Meta) are assumed to be "sticky"; each modifier should be held down (e.g. only a keydown event) until either the modifier is encountered again in the sequence, or the NULL('null') (U+E000) key is encountered.
      - Each key sequence is terminated with an implicit NULL key. Subsequently, all depressed modifier keys must be released (with corresponding keyup events) at the end of the sequence.
     """
     spec :post, "/session/:sessionId/element/:id/value" do
       [
        name:
          :session_page_element_value, # ???
        args:
          [value :: string],
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If the element referenced by :id is no longer attached to the page's DOM.
           ElementNotVisible # If the referenced element is not visible on the page (either is hidden by CSS, has 0-width, or has 0-height)
          ]
       ]
     end

     @doc """
     Send a sequence of key strokes to the active element.
     This command is similar to the send keys command in every aspect except
     the implicit termination: The modifiers are not released at the end of the
     call. Rather, the state of the modifier keys is kept between calls,
     so mouse interactions can be performed while modifier keys are depressed.
     """
     spec :post, "/session/:sessionId/keys" do
       [
        name:
          :session_keys,
        args:
          [value :: string], # key sequence to send
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Query for an element's tag name.
     """
     spec :get, "/session/:sessionId/name" do
       [
        name:
          :session_name,
        args:
          nil,
        returns:
          [tag :: string],
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Clear a TEXTAREA or text INPUT element's value.
     """
     spec :post, "/session/:sessionId/element/:id/clear" do
       [
        name:
          :session_element_clear,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference, # If the element referenced by :id is no longer attached to the page's DOM.
           ElementNotVisible, # If the referenced element is not visible on the page (either is hidden by CSS, has 0-width, or has 0-height)
           InvalidElementState # If the referenced element is disabled.
          ]
       ]
     end

     @doc """
     Determine if an OPTION element, or an INPUT element of type checkbox
     or radiobutton is currently selected.
     """
     spec :get, "/session/:sessionId/element/:id/selected" do
       [
        name:
          :session_element_selected,
        args:
          nil,
        returns:
          boolean,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Determine if an element is currently enabled.
     """
     spec :get, "/session/:sessionId/element/:id/enabled" do
       [
        name:
          :session_element_enabled,
        args:
          nil,
        returns:
          boolean,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Get the value of an element's attribute.
     """
     spec :get, "/session/:sessionId/element/:id/attribute/:name" do
       [
        name:
          :session_element_attribute,
        args:
          nil,
        returns:
          string | nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Test if two element IDs refer to the same DOM element.
     """
     spec :get, "/session/:sessionId/element/:id/equals/:other" do
       [
        name:
          :session_element_equals,
        args:
          nil,
        returns:
          boolean,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Determine if an element is currently displayed.
     """
     spec :get, "/session/:sessionId/element/:id/displayed" do
       [
        name:
          :session_element_displayed,
        args:
          nil,
        returns:
          boolean,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Determine an element's location on the page.
     The point (0, 0) refers to the upper-left corner of the page.
     The element's coordinates are returned as a JSON object with x and y properties.
     """
     spec :get, "/session/:sessionId/element/:id/location" do
       [
        name:
          :session_element_location,
        args:
          nil,
        returns:
          [x :: integer, y :: integer],
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Determine an element's location on the screen once it has
     been scrolled into view.

     Note: This is considered an internal command and should only be used
     to determine an element's location for correctly generating native events.
     """
     spec :get, "/session/:sessionId/element/:id/location_in_view" do
       [
        name:
          :session_element_location_in_view,
        args:
          nil,
        returns:
          [x :: integer, y :: integer],
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Determine an element's size in pixels.
     The size will be returned as a JSON object with width and height properties.
     """
     spec :get, "/session/:sessionId/element/:id/size" do
       [
        name:
          :session_element_size,
        args:
          nil,
        returns:
          [width :: integer, height :: integer],
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Query the value of an element's computed CSS property.
     The CSS property to query should be specified using the CSS property name,
     not the JavaScript property name (e.g. background-color instead of backgroundColor).
     """
     spec :get, "/session/:sessionId/element/:id/css/:propertyName" do
       [
        name:
          :session_element_css_property,
        args:
          nil,
        returns:
          [value :: string],
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Get the current browser orientation.
     The server should return a valid orientation value as defined in
     ScreenOrientation: {LANDSCAPE|PORTRAIT}.
     """
     spec :get, "/session/:sessionId/orientation" do
       [
        name:
          :session_orientation,
        args:
          nil,
        returns:
          [orientation :: orientation],
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Set the browser orientation. The orientation should be specified as defined
     in ScreenOrientation: {LANDSCAPE|PORTRAIT}.
     """
     spec :post, "/session/:sessionId/orientation" do
       [
        name:
          :session_change_orientation,
        args:
          [orientation :: orientation],
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow, # If the currently selected window has been closed.
           StaleElementReference # If the element referenced by :id is no longer attached to the page's DOM.
          ]
       ]
     end

     @doc """
     Gets the text of the currently displayed JavaScript
     alert(), confirm(), or prompt() dialog.
     """
     spec :get, "/session/:sessionId/alert_text" do
       [
        name:
          :session_get_alert_text,
        args:
          nil,
        returns:
          [text :: string],
        exceptions:
          [
           NoAlertPresent
          ]
       ]
     end

     @doc """
     Sends keystrokes to a JavaScript prompt() dialog.
     """
     spec :post, "/session/:sessionId/alert_text" do
       [
        name:
          :session_set_alert_text,
        args:
          [text :: string],
        returns:
          nil,
        exceptions:
          [
           NoAlertPresent
          ]
       ]
     end

     @doc """
     Accepts the currently displayed alert dialog. Usually, this is equivalent
     to clicking on the 'OK' button in the dialog.
     """
     spec :post, "/session/:sessionId/accept_alert" do
       [
        name:
          :session_accept_alert,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoAlertPresent
          ]
       ]
     end

     @doc """
     Dismisses the currently displayed alert dialog.
     For confirm() and prompt() dialogs, this is equivalent to clicking
     the 'Cancel' button. For alert() dialogs, this is equivalent to clicking
     the 'OK' button.
     """
     spec :post, "/session/:sessionId/dismiss_alert" do
       [
        name:
          :session_dismiss_alert,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoAlertPresent
          ]
       ]
     end

     @doc """
     Move the mouse by an offset of the specificed element.
     If no element is specified, the move is relative to the current mouse cursor.
     If an element is provided but no offset, the mouse will be moved to
     the center of the element. If the element is not visible, it will be
     scrolled into view.
     """
     spec :post, "/session/:sessionId/moveto" do
       [
        name:
          :session_moveto,
        args:
          [element :: string, xoffset :: integer, yoffset :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Click any mouse button (at the coordinates set by the last moveto command).
     Note that calling this command after calling buttondown and before calling
     button up (or any out-of-order interactions sequence) will yield undefined
     behaviour).
     """
     spec :post, "/session/:sessionId/click" do
       [
        name:
          :session_click,
        args:
          [button :: button],
        returns:
          nil
       ]
     end

     @doc """
     Click and hold the left mouse button (at the coordinates set by the last
     moveto command). Note that the next mouse-related command that should follow
     is buttondown . Any other mouse command (such as click or another call
     to buttondown) will yield undefined behaviour.
     """
     spec :post, "/session/:sessionId/buttondown" do
       [
        name:
          :session_button_down,
        args:
          [button :: button],
        returns:
          nil
       ]
     end

     @doc """
     Releases the mouse button previously held (where the mouse is currently at).
     Must be called once for every buttondown command issued. See the note in
     click and buttondown about implications of out-of-order commands.
     """
     spec :post, "/session/:sessionId/buttonup" do
       [
        name:
          :session_button_up,
        args:
          [button :: button],
        returns:
          nil
       ]
     end

     @doc """
     Double-clicks at the current mouse coordinates (set by moveto).
     """
     spec :post, "/session/:sessionId/doubleclick" do
       [
        name:
          :session_double_click,
        args:
          nil,
        returns:
          nil
       ]
     end

     @doc """
     Single tap on the touch enabled device.
     """
     spec :post, "/session/:sessionId/touch/click" do
       [
        name:
          :session_touch_click,
        args:
          [element :: id],
        returns:
          nil
       ]
     end

     @doc """
     Finger down on the screen.
     """
     spec :post, "/session/:sessionId/touch/down" do
       [
        name:
          :session_touch_down,
        args:
          [x :: integer, y :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Finger up on the screen.
     """
     spec :post, "/session/:sessionId/touch/up" do
       [
        name:
          :session_touch_up,
        args:
          [x :: integer, y :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Finger move on the screen.
     """
     spec :post, "/session/:sessionId/touch/move" do
       [
        name:
          :session_touch_move,
        args:
          [x :: integer, y :: integer],
        returns:
          nil
       ]
     end

     # FIXME how to define functions with different args
     @doc """
     Scroll on the touch screen using finger based motion events.
     Use this command to start scrolling at a particular screen location.
     """
     spec :post, "/session/:sessionId/touch/scroll" do
       [
        name:
          :session_touch_scroll,
        args:
          [element :: id, x :: integer, y :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Double tap on the touch screen using finger motion events.
     """
     spec :post, "/session/:sessionId/touch/doubleclick" do
       [
        name:
          :session_touch_doubleclick,
        args:
          [element :: id],
        returns:
          nil
       ]
     end

     @doc """
     Long press on the touch screen using finger motion events.
     """
     spec :post, "/session/:sessionId/touch/longclick" do
       [
        name:
          :session_touch_longclick,
        args:
          [element :: id],
        returns:
          nil
       ]
     end

     @doc """
     Flick on the touch screen using finger motion events.
     This flickcommand starts at a particulat screen location.

     Speed is in pixels per second.
     """
     spec :post, "/session/:sessionId/touch/flick" do
       [
        name:
          :session_touch_flick,
        args:
          [element :: id, xoffset :: integer, yoffset :: integer, speed :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Flick on the touch screen using finger motion events.
     Use this flick command if you don't care where the flick starts on the screen.
     Speed is in pixels per second.
     """
     spec :post, "/session/:sessionId/touch/flick" do
       [
        name:
          :session_touch_flick,
        args:
          [xspeed :: integer, yspeed :: integer],
        returns:
          nil
       ]
     end

     @doc """
     Get the current geo location.
     """
     spec :get, "/session/:sessionId/location" do
       [
        name:
          :session_location,
        args:
          nil,
        returns:
          [location :: Location]
       ]
     end

     @doc """
     Set the current geo location.
     """
     spec :post, "/session/:sessionId/location" do
       [
        name:
          :session_set_location,
        args:
          [location :: Location],
        returns:
          nil
       ]
     end

     @doc """
     Get all keys of the storage.
     """
     spec :get, "/session/:sessionId/local_storage" do
       [
        name:
          :session_local_storage,
        args:
          nil,
        returns:
          [keys :: [string]],
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Set the storage item for the given key.
     """
     spec :post, "/session/:sessionId/local_storage" do
       [
        name:
          :session_local_storage,
        args:
          [key :: string, value :: string],
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Clear the storage.
     """
     spec :delete, "/session/:sessionId/local_storage" do
       [
        name:
          :session_clear_local_storage,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Get the storage item for the given key.
     """
     spec :get, "/session/:sessionId/local_storage/key/:key" do
       [
        name:
          :session_local_storage_key,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Remove the storage item for the given key.
     """
     spec :delete, "/session/:sessionId/local_storage/key/:key" do
       [
        name:
          :session_local_storage_key,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Get the number of items in the storage.
     """
     spec :get, "/session/:sessionId/local_storage/size" do
       [
        name:
          :session_local_storage_size,
        args:
          nil,
        returns:
          integer,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Get all keys of the storage.
     """
     spec :get, "/session/:sessionId/session_storage" do
       [
        name:
          :session_storage_keys,
        args:
          nil,
        returns:
          [keys :: [string]],
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Set the storage item for the given key.
     """
     spec :post, "/session/:sessionId/session_storage" do
       [
        name:
          :session_storage_keys,
        args:
          [key :: string, value :: string],
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Clear the storage.
     """
     spec :delete, "/session/:sessionId/session_storage" do
       [
        name:
          :session_storage_keys,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Get the storage item for the given key.
     """
     spec :get, "/session/:sessionId/session_storage/key/:key" do
       [
        name:
          :session_storage_key,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Remove the storage item for the given key.
     """
     spec :delete, "/session/:sessionId/session_storage/key/:key" do
       [
        name:
          :session_storage_key,
        args:
          nil,
        returns:
          nil,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Get the number of items in the storage.
     """
     spec :get, "/session/:sessionId/session_storage/size" do
       [
        name:
          :session_storage_size,
        args:
          nil,
        returns:
          integer,
        exceptions:
          [
           NoSuchWindow
          ]
       ]
     end

     @doc """
     Get the log for a given log type. Log buffer is reset after each request.
     """
     spec :get, "/session/:sessionId/log" do
       [
        name:
          :session_log,
        args:
          [type :: log_type],
        returns:
          [entries :: [Event]]
       ]
     end

     @doc """
     Get available log types.
     """
     spec :get, "/session/:sessionId/log/types" do
       [
        name:
          :session_log,
        args:
          nil,
        returns:
          [types :: [log_type]]
       ]
     end

end