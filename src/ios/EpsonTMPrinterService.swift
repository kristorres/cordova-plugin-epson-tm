import Foundation

/// A service for printing receipts from an Epson TM printer.
@objc(EpsonTMPrinterService)
final class EpsonTMPrinterService: CDVPlugin, Epos2DiscoveryDelegate {

    /// The target of the current printer.
    private var printerTarget: String?

    /// Indicates whether the service is currently searching for printers.
    private var isSearchingForPrinters = false

    // MARK: Public API

    /// Prints a receipt using the command arguments from Cordova.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(printReceipt:)
    func printReceipt(command: CDVInvokedUrlCommand) {
        let printerModel = command.arguments[0] as! Int32

        guard let printer = connectPrinter(printerModel) else {
            sendError(1, with: command)
            return
        }

        let lines = command.arguments[1] as! [String]
        let includeCustomerCopy = command.arguments[2] as? Bool ?? true

        let receiptIsPrinted = printReceipt(
            from: printer,
            lines: lines,
            includeCustomerCopy: includeCustomerCopy
        )

        if !receiptIsPrinted {
            sendError(2, with: command)
            return
        }

        printer.disconnect()

        sendSuccess(with: command)
    }

    /// Starts searching for an Epson TM printer.
    ///
    /// This method will keep running in the background until either a printer
    /// is found or `stopPrinterSearch(command:)` is called.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(startPrinterSearch:)
    func startPrinterSearch(command: CDVInvokedUrlCommand) {
        if isSearchingForPrinters {
            sendSuccess(with: command)
            return
        }

        let filterOption = Epos2FilterOption()
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue

        Epos2Discovery.start(filterOption, delegate: self)
        isSearchingForPrinters = true

        sendSuccess(with: command)
    }

    /// Stops searching for an Epson TM printer.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(stopPrinterSearch:)
    func stopPrinterSearch(command: CDVInvokedUrlCommand) {
        if !isSearchingForPrinters {
            sendSuccess(with: command)
            return
        }

        Epos2Discovery.stop()
        isSearchingForPrinters = false

        sendSuccess(with: command)
    }

    // MARK: Protocol conformance

    func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        Epos2Discovery.stop()
        isSearchingForPrinters = false

        printerTarget = deviceInfo?.target
    }

    // MARK: Private methods

    /// Starts communication with a printer of the specified model.
    ///
    /// - Parameter model: The printer model.
    ///
    /// - Returns: The connected printer.
    private func connectPrinter(_ model: Int32) -> Epos2Printer? {
        guard let printerTarget = self.printerTarget else {
            return nil
        }

        let printer = Epos2Printer(
            printerSeries: model,
            lang: EPOS2_MODEL_ANK.rawValue
        )

        let result = printer?.connect(
            printerTarget,
            timeout: Int(EPOS2_PARAM_DEFAULT)
        )

        if result != EPOS2_SUCCESS.rawValue {
            printer?.disconnect()
            printer?.connect(printerTarget, timeout: Int(EPOS2_PARAM_DEFAULT))
        }

        return printer
    }

    /// Prints a receipt.
    ///
    /// - Parameter printer:             The printer.
    /// - Parameter lines:               The lines on the receipt.
    /// - Parameter includeCustomerCopy: Indicates whether a second copy of the
    ///                                  receipt will be printed.
    ///
    /// - Returns: `true` if the receipt is printed, or `false` otherwise.
    private func printReceipt(
        from printer: Epos2Printer,
        lines: [String],
        includeCustomerCopy: Bool
    ) -> Bool {
        let text = lines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            return false
        }

        let copyCount = includeCustomerCopy
            ? 2
            : 1

        printer.beginTransaction()

        for _ in 0 ..< copyCount {
            printer.addText(text)
            printer.addFeedLine(2)
            printer.addCut(EPOS2_CUT_FEED.rawValue)
        }

        printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        printer.clearCommandBuffer()
        printer.endTransaction()

        return true
    }

    /// Sends an error to the command delegate.
    ///
    /// - Parameter errorCode: The error code.
    /// - Parameter command:   The invoked command from Cordova.
    private func sendError(
        _ errorCode: Int,
        with command: CDVInvokedUrlCommand
    ) {
        let result = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: errorCode
        )

        commandDelegate?.send(result, callbackId: command.callbackId)
    }

    /// Sends a “success” to the command delegate.
    ///
    /// - Parameter command: The invoked command from Cordova.
    private func sendSuccess(with command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: true
        )

        commandDelegate?.send(result, callbackId: command.callbackId)
    }
}
