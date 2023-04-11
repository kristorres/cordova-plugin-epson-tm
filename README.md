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

API
---

The `EpsonTM` object has constants for the following compatible printer models:

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

Additionally, but most importantly, the `EpsonTM` object has three methods.
Ideally, they should be used in the same component (yes, this plugin is
UI-library-agnostic).

  * `printReceipt(args, success, error)`
  * `startPrinterSearch(success, error)`
  * `stopPrinterSearch(success, error)`

### `printReceipt(args, success, error)`

Prints a receipt using the specified `args`.

**Parameters:**

  * `args` — An object that contains the following properties:
    * `model` — The Epson TM printer model (e.g., `EpsonTM.m30`).
    * `lines` — The lines on the receipt.
    * `includeCustomerCopy` — Indicates whether a second copy of the receipt
      will be printed. The default is `false`.
  * `success` — A callback to invoke when the receipt is printed. It passes
    `true`.
  * `error` — A callback to invoke when there is an error. It passes one of the
    following errors:
    * `PRINTER_NOT_FOUND` — An Epson TM printer was not found by the service.
    * `INVALID_PRINTER_MODEL` — The Epson TM printer model is invalid.
    * `CANNOT_CONNECT_PRINTER` — The service cannot connect to an Epson TM
      printer.
    * `BLANK_RECEIPT` — The receipt is blank.

```javascript
EpsonTM.printReceipt(
    {
        model: EpsonTM.m30,
        lines: [
            "        BUSINESS NAME         ",
            "       1234 Main Street       ",
            "        City, ST 54321        ",
            "        1(123)456-7890        ",
            "------------------------------",
            "Lorem ipsum              $1.25",
            "Dolor sit amet           $7.99",
            "Consectetur             $26.70",
            "Adipiscing elit         $15.49",
            "Sed semper              $18.79",
            "Accumsan ante           $42.99",
            "Non laoreet              $9.99",
            "Dui dapibus eu          $27.50\n",

            "Sub Total              $150.70",
            "Sales Tax                $5.29",
            "------------------------------",
            "TOTAL                  $155.99",
        ],
        includeCustomerCopy: true,
    },
    (result) => console.log(`Success? ${result}`),
    (error) => {
        if (error === EpsonTM.Error.CANNOT_CONNECT_PRINTER) {
            console.log("Cannot connect to a printer.")
        }
    }
)
```

### `startPrinterSearch(success, error)`

Starts searching for an Epson TM printer.

This method will keep running in the background until either a printer is found
or the `stopPrinterSearch` method is called. Ideally, it should be called when
the component is created.

**Parameters:**

  * `success` — A callback to invoke when the printer search is started.
    It passes `true`.
  * `error` — A callback to invoke when there is an error. It passes the error
    `CANNOT_START_PRINTER_SEARCH`.

```javascript
EpsonTM.startPrinterSearch(
    (result) => console.log(`Success? ${result}`),
    (error) => {
        if (error === EpsonTM.Error.CANNOT_START_PRINTER_SEARCH) {
            console.log("Cannot start printer search.")
        }
    }
)
```

### `stopPrinterSearch(success, error)`

Stops searching for an Epson TM printer.

Ideally, this method should be called when the component is destroyed.

**Parameters:**

  * `success` — A callback to invoke when the printer search is stopped.
    It passes `true`.
  * `error` — A callback to invoke when there is an error. It passes the error
    `CANNOT_STOP_PRINTER_SEARCH`.

```javascript
EpsonTM.stopPrinterSearch(
    (result) => console.log(`Success? ${result}`),
    (error) => {
        if (error === EpsonTM.Error.CANNOT_STOP_PRINTER_SEARCH) {
            console.log("Cannot stop printer search.")
        }
    }
)
```

Component Example
-----------------

Here is how one would use the plugin in a Svelte component:

```svelte
<script>
    import {onDestroy, onMount} from "svelte"

    const printReceipt = () => {
        EpsonTM.printReceipt(
            {
                model: EpsonTM.m30,
                lines: receiptLines,
                includeCustomerCopy: true,
            },
            (result) => {},
            (error) => {
                // Handle the error here.
            }
        )
    }

    onMount(
        () => EpsonTM.startPrinterSearch()
    )

    onDestroy(
        () => EpsonTM.stopPrinterSearch()
    )
</script>

<button on:click={printReceipt}>
    Print Receipt
</button>
```

For a more concrete example, please check out
[this repo](https://github.com/kristorres/epson-tm-demo).
