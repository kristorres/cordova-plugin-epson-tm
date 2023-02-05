import Foundation

/// A service for printing receipts from an Epson TM printer.
@objc(EpsonTMPrinterService)
final class EpsonTMPrinterService:
    CDVPlugin,
    Epos2DiscoveryDelegate,
    Epos2PtrReceiveDelegate
{
    /// The current printer.
    private var printer: Epos2Printer?

    /// The target of the current printer.
    private var printerTarget: String?

    /// Indicates whether the service is currently searching for an Epson TM
    /// printer.
    private var isSearchingForPrinter = false

    // MARK: Public API

    /// Prints a receipt using the command arguments from Cordova.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(printReceipt:)
    func printReceipt(command: CDVInvokedUrlCommand) {
        commandDelegate?.run { [weak self] in
            let printerModel = command.arguments[0] as! Int32

            if let error = self?.connectPrinter(printerModel) {
                self?.sendError(error, with: command)
                return
            }

            let lines = command.arguments[1] as! [String]
            let includeCustomerCopy = command.arguments[2] as? Bool ?? true

            if let error = self?.printReceipt(
                lines: lines,
                includeCustomerCopy: includeCustomerCopy
            ) {
                self?.sendError(error, with: command)
                return
            }

            self?.disconnectPrinter()

            self?.sendSuccess(with: command)
        }
    }

    /// Starts searching for an Epson TM printer.
    ///
    /// This method will keep running in the background until either a printer
    /// is found or `stopPrinterSearch(command:)` is called.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(startPrinterSearch:)
    func startPrinterSearch(command: CDVInvokedUrlCommand) {
        if isSearchingForPrinter {
            sendSuccess(with: command)
            return
        }

        let filterOption = Epos2FilterOption()
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue

        let result = Epos2Discovery.start(filterOption, delegate: self)

        if result != EPOS2_SUCCESS.rawValue {
            sendError(.cannotStartPrinterSearch, with: command)
            return
        }

        isSearchingForPrinter = true
        sendSuccess(with: command)
    }

    /// Stops searching for an Epson TM printer.
    ///
    /// - Parameter command: The invoked command from Cordova.
    @objc(stopPrinterSearch:)
    func stopPrinterSearch(command: CDVInvokedUrlCommand) {
        if !isSearchingForPrinter {
            sendSuccess(with: command)
            return
        }

        let result = Epos2Discovery.stop()

        if result != EPOS2_SUCCESS.rawValue {
            sendError(.cannotStopPrinterSearch, with: command)
            return
        }

        isSearchingForPrinter = false
        sendSuccess(with: command)
    }

    // MARK: Protocol conformance

    func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        var result = EPOS2_SUCCESS.rawValue

        repeat {
            result = Epos2Discovery.stop()
        }
        while result != EPOS2_SUCCESS.rawValue

        isSearchingForPrinter = false
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

    /// Starts communication with a printer of the specified model.
    ///
    /// - Note: This method must be called from a background thread only.
    ///
    /// - Parameter model: The printer model.
    ///
    /// - Returns: An error if the method fails, or `nil` otherwise.
    private func connectPrinter(_ model: Int32) -> EpsonTMError? {
        if printerTarget == nil {
            return .printerNotFound
        }

        printer = Epos2Printer(
            printerSeries: model,
            lang: EPOS2_MODEL_ANK.rawValue
        )

        if printer == nil {
            return .invalidPrinterModel
        }

        printer?.setReceiveEventDelegate(self)

        let result = printer?.connect(
            printerTarget,
            timeout: Int(EPOS2_PARAM_DEFAULT)
        )

        if result != EPOS2_SUCCESS.rawValue {
            return .cannotConnectPrinter
        }

        return nil
    }

    /// Ends communication with the printer.
    ///
    /// - Note: This method must be called from a background thread only.
    private func disconnectPrinter() {
        printer?.disconnect()
        printer?.setReceiveEventDelegate(nil)

        printer = nil
    }

    /// Prints a receipt.
    ///
    /// - Parameter lines:               The lines on the receipt.
    /// - Parameter includeCustomerCopy: Indicates whether a second copy of the
    ///                                  receipt will be printed.
    ///
    /// - Returns: An error if the method fails, or `nil` otherwise.
    private func printReceipt(
        lines: [String],
        includeCustomerCopy: Bool
    ) -> EpsonTMError? {
        let text = lines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            return .blankReceipt
        }

        let copyCount = includeCustomerCopy
            ? 2
            : 1

        for _ in 0 ..< copyCount {
            printer?.addText(text)
            printer?.addFeedLine(2)
            printer?.addCut(EPOS2_CUT_FEED.rawValue)
        }

        printer?.sendData(Int(EPOS2_PARAM_DEFAULT))
        printer?.clearCommandBuffer()

        return nil
    }

    /// Sends an error to the command delegate.
    ///
    /// - Parameter error:   The error to be sent.
    /// - Parameter command: The invoked command from Cordova.
    private func sendError(
        _ error: EpsonTMError,
        with command: CDVInvokedUrlCommand
    ) {
        let result = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: error.rawValue
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
