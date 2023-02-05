Epson TM Printer Service
========================

<p>
    <img src="https://img.shields.io/badge/Cordova-11+-e8e8e8?style=for-the-badge&logo=apache-cordova" />
    <img src="https://img.shields.io/badge/Cordova%20iOS-6+-e8e8e8?style=for-the-badge&logo=apache-cordova" />
    <img src="https://img.shields.io/badge/iOS-11+-lightgrey?style=for-the-badge&logo=apple" />
    <img src="https://img.shields.io/badge/Swift-4+-f05339?style=for-the-badge&logo=swift" />
</p>

A simple Cordova plugin for printing receipts from an Epson TM printer. 🧾🖨️

This plugin defines a global `EpsonTM` object, which is available after the
`deviceready` event.

> **IMPORTANT:** If you are building an app with this plugin for a simulator on
> a Mac with Apple Silicon, then you may encounter a build error. To resolve the
> issue, exclude `arm64` for the simulator SDK under both
> *&lt;Project&gt;.xcodeproj* and *CordovaLib.xcodeproj*. See technote
> [TN3117](https://developer.apple.com/documentation/technotes/tn3117-resolving-build-errors-for-apple-silicon)
> for more details.

Installation
------------

```sh
cordova plugin add cordova-plugin-epson-tm
```

Compatible Printer Model Constants
----------------------------------

  * `m10`
  * `m30`
  * `P20`
  * `P60`
  * `P60II`
  * `P80`
  * `T20`
  * `T60`
  * `T70`
  * `T81`
  * `T82`
  * `T83`
  * `T88`
  * `T90`
  * `T90KP`
  * `U220`
  * `U330`
  * `L90`
  * `H6000`
  * `T83III`
  * `T100`

Error Code Constants
--------------------

  * `CANNOT_START_PRINTER_SEARCH`
  * `CANNOT_STOP_PRINTER_SEARCH`
  * `PRINTER_NOT_FOUND`
  * `INVALID_PRINTER_MODEL`
  * `CANNOT_CONNECT_PRINTER`
  * `BLANK_RECEIPT`

Methods
-------

The `EpsonTM` object has three methods. Ideally, they should be used in the same
component (yes, this plugin is UI-library-agnostic).

  * `printReceipt(args, success, error)`
  * `startPrinterSearch(success, error)`
  * `stopPrinterSearch(success, error)`

### `printReceipt(args, success, error)`

Prints a receipt using the specified `args`.

**Parameters:**

  * `args` — An object that contains the following properties:
    * `model` — The printer model (e.g., `EpsonTM.m30`).
    * `lines` — The lines on the receipt.
    * `includeCustomerCopy` — Indicates whether a second copy of the receipt
      will be printed. The default is `false`.
  * `success` — A callback to invoke when the receipt is printed. Its only
    argument is `true`.
  * `error` — A callback to invoke when there is an error. Its only argument is
    an error code.

### `startPrinterSearch(success, error)`

Starts searching for an Epson TM printer.

This method will keep running in the background until either a printer is found
or the `stopPrinterSearch` method is called.

**Parameters:**

  * `success` — A callback to invoke when the receipt is printed. Its only
    argument is `true`.
  * `error` — A callback to invoke when there is an error. Its only argument is
    `CANNOT_START_PRINTER_SEARCH`.

### `stopPrinterSearch(success, error)`

Stops searching for an Epson TM printer.

**Parameters:**

  * `success` — A callback to invoke when the receipt is printed. Its only
    argument is `true`.
  * `error` — A callback to invoke when there is an error. Its only argument is
    `CANNOT_STOP_PRINTER_SEARCH`.
