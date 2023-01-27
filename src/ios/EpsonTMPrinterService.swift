import Foundation

/// A service for printing receipts from an Epson TM printer.
@objc(EpsonTMPrinterService)
final class EpsonTMPrinterService:
    CDVPlugin,
    Epos2DiscoveryDelegate,
    Epos2PtrReceiveDelegate
{
    /// The target of the current printer.
    private var printerTarget: String?

    // MARK: Public API

    /// Prints a receipt using the command arguments from Cordova.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(printReceipt:)
    func printReceipt(command: CDVInvokedUrlCommand) {
        guard let printerTarget = self.printerTarget else {
            let message = "Please connect to a Bluetooth printer and try again."
            sendError(message, command: command)
            return
        }

        let lines = command.arguments[1] as! [String]
        let text = lines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            sendError("The receipt is blank.", command: command)
            return
        }

        let printerSeries = command.arguments[0] as! Int32

        guard let printer = setUpPrinter(series: printerSeries) else {
            let message = "Invalid printer series: \(printerSeries)."
            sendError(message, command: command)
            return
        }

        let connectionResult = printer.connect(
            printerTarget,
            timeout: Int(EPOS2_PARAM_DEFAULT)
        )

        if connectionResult != EPOS2_SUCCESS.rawValue {
            printer.disconnect()
            printer.connect(printerTarget, timeout: Int(EPOS2_PARAM_DEFAULT))
        }

        let includeCustomerCopy = command.arguments[2] as? Bool ?? true

        printer.beginTransaction()
        printCopy(from: printer, text: text)
        if includeCustomerCopy {
            printCopy(from: printer, text: text)
        }
        printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        printer.clearCommandBuffer()
        printer.endTransaction()

        printer.disconnect()

        sendSuccess(command: command)
    }

    /// Starts searching for an Epson TM printer.
    ///
    /// This method will keep running in the background until either a printer
    /// is found or `stopPrinterSearch(command:)` is called.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(startPrinterSearch:)
    func startPrinterSearch(command: CDVInvokedUrlCommand) {
        let filterOption = Epos2FilterOption()
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue

        Epos2Discovery.start(filterOption, delegate: self)
    }

    /// Stops searching for an Epson TM printer.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(stopPrinterSearch:)
    func stopPrinterSearch(command: CDVInvokedUrlCommand) {
        Epos2Discovery.stop()
    }

    // MARK: Protocol conformance

    func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        Epos2Discovery.stop()

        printerTarget = deviceInfo?.target
    }

    func onPtrReceive(
        _ printerObj: Epos2Printer!,
        code: Int32,
        status: Epos2PrinterStatusInfo!,
        printJobId: String!
    ) {
    }

    // MARK: Private methods

    /// Prints a receipt copy from the specified printer.
    ///
    /// - Parameter printer: The printer.
    /// - Parameter text:    The text on the receipt.
    private func printCopy(from printer: Epos2Printer, text: String) {
        printer.addText(text)
        printer.addFeedLine(2)
        printer.addCut(EPOS2_CUT_FEED.rawValue)
    }

    /// Sends an error with the specified message to the command delegate.
    ///
    /// - Parameter message: The error message.
    /// - Parameter command: The invoked command from Cordova.
    private func sendError(_ message: String, command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAsString: message
        )

        commandDelegate?.send(result, callbackId: command.callbackId)
    }

    /// Sends a “success” to the command delegate.
    ///
    /// - Parameter command: The invoked command from Cordova.
    private func sendSuccess(command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAsBool: true
        )

        commandDelegate?.send(result, callbackId: command.callbackId)
    }

    /// Returns a printer in the specified series.
    ///
    /// - Parameter series: The printer series.
    private func setUpPrinter(series: Int32) -> Epos2Printer? {
        let printer = Epos2Printer(
            printerSeries: series,
            lang: EPOS2_MODEL_ANK.rawValue
        )

        printer?.setReceiveEventDelegate(self)

        return printer
    }
}
