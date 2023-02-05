import Foundation

/// A possible error that can be returned from an Epson TM printer service.
enum EpsonTMError: Int, Error {

    /// An error indicating the service cannot start searching for an Epson TM
    /// printer.
    case cannotStartPrinterSearch = 1

    /// An error indicating the service cannot stop searching for an Epson TM
    /// printer.
    case cannotStopPrinterSearch

    /// An error indicating an Epson TM printer was not found by the service.
    case printerNotFound

    /// An error indicating an invalid Epson TM printer model.
    case invalidPrinterModel

    /// An error indicating the service cannot connect to an Epson TM printer.
    case cannotConnectPrinter

    /// An error indicating a blank receipt.
    case blankReceipt
}
